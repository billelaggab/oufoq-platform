# ===== Flutter Wrapper =====
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ===== Google Mobile Ads & UMP Consent SDK =====
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.ump.** { *; }
-dontwarn com.google.errorprone.annotations.**

# ===== Firebase =====
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ===== Dio / Gson-ish serialization safety =====
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.oufoq.platform.** { *; }
