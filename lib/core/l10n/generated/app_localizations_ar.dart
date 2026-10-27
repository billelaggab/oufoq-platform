// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'منصة أفق';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'الأقسام';

  @override
  String get navBookmarks => 'المحفوظات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get clear => 'مسح';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get errorNoInternet =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجدداً.';

  @override
  String get errorServer =>
      'تعذّر الاتصال بالخادم حالياً. يرجى المحاولة لاحقاً.';

  @override
  String get errorTimeout => 'انتهت مهلة الاتصال. حاول مرة أخرى.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get errorEmptyCache => 'لا توجد بيانات محفوظة بعد.';

  @override
  String get errorViewTitle => 'حدث خطأ ما';

  @override
  String get errorViewBody => 'تعذّر تحميل المحتوى، يمكنك إعادة المحاولة.';

  @override
  String get emptyDefaultTitle => 'لا يوجد محتوى هنا بعد';

  @override
  String get emptyDefaultBody => 'ستظهر هنا أحدث الأخبار فور توفرها.';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String readingTimeMinutes(int count) {
    return '$count دقائق قراءة';
  }

  @override
  String get breakingLabel => 'عاجل';

  @override
  String get featuredSection => 'الأخبار البارزة';

  @override
  String get latestNews => 'أحدث الأخبار';

  @override
  String get categoryAllChip => 'الكل';

  @override
  String get offlineBanner =>
      'أنت غير متصل بالإنترنت — يتم عرض آخر المحتوى المحفوظ';

  @override
  String get searchButtonLabel => 'بحث';

  @override
  String get searchHint => 'ابحث في الأخبار…';

  @override
  String get searchHistoryTitle => 'عمليات البحث الأخيرة';

  @override
  String get clearHistory => 'مسح السجل';

  @override
  String get searchEmptyTitle => 'لا توجد نتائج مطابقة';

  @override
  String get searchEmptyBody => 'جرّب كلمات بحث مختلفة للعثور على ما تريد.';

  @override
  String get bookmarksTitle => 'المحفوظات';

  @override
  String get bookmarksEmptyTitle => 'لا توجد مقالات محفوظة';

  @override
  String get bookmarksEmptyBody =>
      'احفظ المقالات التي تهمك لقراءتها لاحقاً بدون إنترنت.';

  @override
  String get bookmarkAdded => 'تم حفظ المقال في المحفوظات';

  @override
  String get bookmarkRemoved => 'تمت إزالة المقال من المحفوظات';

  @override
  String get saveArticle => 'حفظ المقال';

  @override
  String get removeBookmark => 'إزالة من المحفوظات';

  @override
  String get articleNotFound => 'تعذّر العثور على المقال';

  @override
  String get relatedArticles => 'مقالات ذات صلة';

  @override
  String get fontScaleTitle => 'حجم خط القراءة';

  @override
  String get fontSmall => 'صغير';

  @override
  String get fontMedium => 'متوسط';

  @override
  String get fontLarge => 'كبير';

  @override
  String get fontExtraLarge => 'كبير جداً';

  @override
  String get fontPreviewText =>
      'هذا نص تجريبي لمعاينة حجم خط القراءة في منصة أفق.';

  @override
  String get shareArticle => 'مشاركة الخبر';

  @override
  String get openInBrowser => 'فتح في المتصفح';

  @override
  String get openImage => 'فتح الصورة';

  @override
  String get adLabel => 'إعلان';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearanceSection => 'المظهر والقراءة';

  @override
  String get themeModeLabel => 'المظهر';

  @override
  String get themeSystem => 'تلقائي حسب النظام';

  @override
  String get themeLight => 'الوضع النهاري';

  @override
  String get themeDark => 'الوضع الليلي';

  @override
  String get fontScaleSection => 'حجم خط المقالات';

  @override
  String get languageSection => 'اللغة';

  @override
  String get languageLabel => 'لغة التطبيق';

  @override
  String get notificationsSection => 'التنبيهات والبيانات';

  @override
  String get breakingNotificationsLabel => 'إشعارات الأخبار العاجلة';

  @override
  String get dataSection => 'البيانات والتخزين';

  @override
  String get clearCacheLabel => 'مسح الذاكرة المؤقتة';

  @override
  String get cacheClearedMessage =>
      'تم مسح الذاكرة المؤقتة بنجاح، المحفوظات سليمة.';

  @override
  String get aboutSection => 'منصة أفق';

  @override
  String get aboutUs => 'من نحن وهيئة التحرير';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get privacyPolicy => 'سياسة الخصوصية وشروط الاستخدام';

  @override
  String get adsPrivacyOptions => 'إعدادات خصوصية الإعلانات';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get notificationsEnabled => 'تم تفعيل إشعارات الأخبار العاجلة';

  @override
  String get notificationsDisabled => 'تم إيقاف إشعارات الأخبار العاجلة';

  @override
  String get aboutTitle => 'من نحن وهيئة التحرير';

  @override
  String get aboutBody =>
      'منصة أفق مؤسسة إخبارية عربية مستقلة تسعى لتقديم أخبار دقيقة وتقارير معمقة بسرعة ومهنية، مع الالتزام بأخلاقيات الصحافة واحترام عقل القارئ ووقته.';

  @override
  String get editorialBody =>
      'تعمل هيئة التحرير وفق سياسة تحريرية صارمة للتحقق من المعلومات قبل النشر، وتفصل بوضوح بين الخبر والرأي والإعلان.';

  @override
  String get contactTitle => 'اتصل بنا';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get websiteLabel => 'الموقع الإلكتروني';

  @override
  String get categoriesTitle => 'الأقسام';

  @override
  String articlesCount(int count) {
    return '$count مقال';
  }

  @override
  String get notificationChannelName => 'الأخبار العاجلة - منصة أفق';

  @override
  String get notificationChannelDescription =>
      'تنبيهات فورية عند وقوع أحداث عاجلة';
}
