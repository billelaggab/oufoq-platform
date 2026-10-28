import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.GradleException

// نضيف إضافة Firebase إلى classpath فقط عند وجود google-services.json،
// حتى لا تفشل نسخ التطوير أو CI التي لا تحتوي إعداد Firebase.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        if (file("google-services.json").exists()) {
            classpath("com.google.gms:google-services:4.4.2")
        }
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// يُطبَّق فقط عند وجود google-services.json.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val hasReleaseSigning = keystorePropertiesFile.exists() &&
    !keystoreProperties.getProperty("storeFile").isNullOrBlank() &&
    !keystoreProperties.getProperty("keyAlias").isNullOrBlank()

// معرّف AdMob للإصدار: من key.properties أو متغير البيئة.
val releaseAdMobAppId: String? =
    keystoreProperties.getProperty("admobAppId")
        ?: System.getenv("ADMOB_ANDROID_APP_ID")

// يُتحقق منه فقط عند بناء الإصدار، حتى لا تتعطل نسخ التطوير.
gradle.taskGraph.whenReady {
    val buildingRelease =
        allTasks.any { task -> task.name.contains("Release") }
    if (buildingRelease && releaseAdMobAppId.isNullOrBlank()) {
        throw GradleException(
            "ADMOB_ANDROID_APP_ID (or admobAppId in key.properties) " +
                "is required for release builds."
        )
    }
}

android {
    namespace = "com.oufoq.platform"
    // يلزم 36 لأن إضافات Flutter الحالية (google_mobile_ads وconnectivity_plus وغيرها)
    // تُبنى ضد SDK 36، وهي متوافقة رجعياً مع الأجهزة حتى minSdk 23.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    defaultConfig {
        applicationId = "com.oufoq.platform"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // معرّف AdMob التجريبي الرسمي افتراضياً أثناء التطوير
        manifestPlaceholders["admobAppId"] = "ca-app-pub-3940256099942544~3347511713"
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            manifestPlaceholders["admobAppId"] = "ca-app-pub-3940256099942544~3347511713"
        }
        getByName("release") {
            // لا نستخدم توقيع debug في الإصدار مطلقاً؛ إن غاب key.properties
            // يبقى الإصدار غير موقّع بدل إنتاج حزمة غير قابلة للنشر.
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            // منع شحن معرّف AdMob التجريبي في الإصدار.
            manifestPlaceholders["admobAppId"] = releaseAdMobAppId ?: ""
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
