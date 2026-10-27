# منصة أفق — Oufoq Platform

تطبيق أندرويد إخباري عربي احترافي مبني بـ **Flutter (Dart 3)** مربوط بـ **WordPress REST API v2**،
بمعمارية نظيفة حسب الميزة (Feature-First Clean Architecture) وإدارة حالة بـ **Riverpod 3**.

- **معرّف الحزمة:** `com.oufoq.platform`
- **اللغة:** العربية (RTL) حصرياً في الإصدار 1.0، مع بنية جاهزة 100% للإنجليزية والفرنسية
- **الخط:** Tajawal بخمسة أوزان، مدمج محلياً بالكامل
- **تحقيق الدخل:** Google AdMob (بنر متكيف + إعلان مدمج + بيني منضبط) + موافقة UMP
- **الأوفلاين:** حفظ كامل للمقالات في SQLite للقراءة بدون إنترنت

---

## 1. التشغيل محلياً وربط موقع ووردبريس

```bash
flutter pub get
flutter gen-l10n
flutter run
```

رابط موقع ووردبريس يُمرر وقت التشغيل/البناء عبر `--dart-define`
(الافتراضي موقع تجريبي عام للتجربة الفورية):

```bash
flutter run --dart-define=WP_BASE_URL=https://your-wordpress-site.com
```

تأكد أن الرابط التالي يعيد JSON دون حجبه بإضافة أمان:
`https://your-wordpress-site.com/wp-json/wp/v2/posts`

المتغيرات المعتمدة في `lib/core/config/env_config.dart`:

| المتغير | الوصف |
| :--- | :--- |
| `WP_BASE_URL` | الرابط الجذري للموقع (بدون `/wp-json`) |
| `CONTACT_EMAIL` | البريد الرسمي لشاشة "اتصل بنا" |
| `OFFICIAL_WEBSITE` | رابط الموقع الرسمي |
| `PRIVACY_POLICY_URL` | رابط سياسة الخصوصية |
| `BREAKING_CATEGORY_ID` | معرّف قسم الأخبار العاجلة (اختياري) |

---

## 2. تفعيل إشعارات Firebase FCM

1. أنشئ مشروعاً في [Firebase Console](https://console.firebase.google.com) وأضف تطبيق أندرويد
   بمعرّف `com.oufoq.platform`.
2. حمّل ملف `google-services.json` وضعه في:
   ```
   android/app/google-services.json
   ```
3. فعّل إضافة جوجل في `android/app/build.gradle.kts`:
   ```kotlin
   id("com.google.gms.google-services")
   ```
4. التطبيق يعمل **بدون** الملف أيضاً (تشغيل آمن صامت)؛ تتفعّل الإشعارات تلقائياً بمجرد إضافته.
5. اشترك بخادم الموقع في موضوع `breaking_ar` لإرسال الأخبار العاجلة
   (و`breaking_en` / `breaking_fr` مستقبلاً).

---

## 3. معرفات AdMob وبناء نسخة الإنتاج

أثناء التطوير تُستخدم **معرفات الاختبار الرسمية من جوجل تلقائياً** (حماية من حظر الحساب)،
ولا يمكن أبداً استخدام معرف إنتاجي في وضع التصحيح.

أمر البناء النهائي لحزمة Google Play (AAB):

```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --dart-define=WP_BASE_URL=https://your-wordpress-site.com \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXX/BBBB \
  --dart-define=ADMOB_NATIVE_ID=ca-app-pub-XXXX/NNNN \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXX/IIII \
  --dart-define=ADMOB_APP_OPEN_ID=ca-app-pub-XXXX/OOOO
```

معرّف تطبيق AdMob على مستوى أندرويد يُضبط عبر متغير البيئة
`ADMOB_ANDROID_APP_ID` أو ملف `android/key.properties` (مفتاح `admobAppId`).

ارفع ملف `app-ads.txt` إلى جذر نطاق الموقع قبل الإطلاق.

---

## 4. تفعيل الإنجليزية والفرنسية لاحقاً (أقل من 5 دقائق)

1. افتح `lib/core/config/feature_flags.dart`.
2. أضف اللغتين إلى القائمة:
   ```dart
   static const List<Locale> activeLocales = [
     Locale('ar'),
     Locale('en'),
     Locale('fr'),
   ];
   ```
3. نفّذ `flutter gen-l10n`.

سيظهر مبدّل اللغة تلقائياً في شاشة الإعدادات، وينقلب اتجاه الواجهة كاملاً (RTL/LTR)،
وتُمرر باراميتر `lang` تلقائياً لطبقة الشبكة عبر `LanguageInterceptor`،
وتتبدّل موضوعات إشعارات FCM عبر `syncLanguageTopic` — دون تعديل أي شاشة.

---

## 5. أوامر الفحص الإلزامية

```bash
flutter gen-l10n
flutter analyze --no-fatal-infos
flutter test
```

تشمل الحزمة اختبارات لتحليل موديلات ووردبريس، فك كيانات HTML، سياسة الإعلان البيني،
خريطة مواضع الإعلانات المدمجة، قاعدة محفوظات SQLite، واختبار إقلاع الواجهة بالعربية.

### معاينة بصرية داخل المتصفح

التطبيق يستهدف أندرويد حصراً، وتوفَّر معاينة HTML ثابتة مطابقة للهوية (نفس خط Tajawal
والألوان والنصوص المعرّفة في ملفات الترجمة) على الرابط `/preview/`:

```bash
python3 -m http.server 8080 --bind 0.0.0.0
# ثم افتح: http://localhost:8080/preview/
```

---

## 6. بنية المشروع

```text
lib/
├── core/          # الإعدادات، الثيم، الشبكة، التخزين، اللغات، التوجيه، المكونات المشتركة
└── features/      # home, categories, article, bookmarks, search, ads, notifications, settings
assets/
├── fonts/Tajawal/ # خط Tajawal بأوزانه الخمسة
└── images/        # شعارات وصورة افتراضية
scripts/
└── download_tajawal_font.sh
wordpress/
└── oufoq-mobile-app-bridge.php   # إضافة PHP اختيارية للتحكم عن بُعد بالإعلانات
```

## 7. متطلبات البناء للأندرويد

- Android SDK 36 للترجمة (تتطلبه إضافات Flutter الحالية)، وtargetSdk 35، وminSdk 23
- JDK 17 أو أحدث (مبني ومختبَر محلياً على JDK 21)
- يُفعّل R8 (تصغير الموارد والكود) وقواعد ProGuard في `android/app/proguard-rules.pro`
