import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// اسم التطبيق
  ///
  /// In ar, this message translates to:
  /// **'منصة أفق'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get navCategories;

  /// No description provided for @navBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات'**
  String get navBookmarks;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get seeAll;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get loading;

  /// No description provided for @errorNoInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجدداً.'**
  String get errorNoInternet;

  /// No description provided for @errorServer.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالخادم حالياً. يرجى المحاولة لاحقاً.'**
  String get errorServer;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال. حاول مرة أخرى.'**
  String get errorTimeout;

  /// No description provided for @errorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مرة أخرى.'**
  String get errorUnknown;

  /// No description provided for @errorEmptyCache.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات محفوظة بعد.'**
  String get errorEmptyCache;

  /// No description provided for @errorViewTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get errorViewTitle;

  /// No description provided for @errorViewBody.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المحتوى، يمكنك إعادة المحاولة.'**
  String get errorViewBody;

  /// No description provided for @emptyDefaultTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محتوى هنا بعد'**
  String get emptyDefaultTitle;

  /// No description provided for @emptyDefaultBody.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا أحدث الأخبار فور توفرها.'**
  String get emptyDefaultBody;

  /// No description provided for @justNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعة'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} يوم'**
  String daysAgo(int count);

  /// No description provided for @readingTimeMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقائق قراءة'**
  String readingTimeMinutes(int count);

  /// No description provided for @breakingLabel.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get breakingLabel;

  /// No description provided for @featuredSection.
  ///
  /// In ar, this message translates to:
  /// **'الأخبار البارزة'**
  String get featuredSection;

  /// No description provided for @latestNews.
  ///
  /// In ar, this message translates to:
  /// **'أحدث الأخبار'**
  String get latestNews;

  /// No description provided for @categoryAllChip.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get categoryAllChip;

  /// No description provided for @offlineBanner.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل بالإنترنت — يتم عرض آخر المحتوى المحفوظ'**
  String get offlineBanner;

  /// No description provided for @searchButtonLabel.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get searchButtonLabel;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الأخبار…'**
  String get searchHint;

  /// No description provided for @searchHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'عمليات البحث الأخيرة'**
  String get searchHistoryTitle;

  /// No description provided for @clearHistory.
  ///
  /// In ar, this message translates to:
  /// **'مسح السجل'**
  String get clearHistory;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمات بحث مختلفة للعثور على ما تريد.'**
  String get searchEmptyBody;

  /// No description provided for @bookmarksTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مقالات محفوظة'**
  String get bookmarksEmptyTitle;

  /// No description provided for @bookmarksEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'احفظ المقالات التي تهمك لقراءتها لاحقاً بدون إنترنت.'**
  String get bookmarksEmptyBody;

  /// No description provided for @bookmarkAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المقال في المحفوظات'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In ar, this message translates to:
  /// **'تمت إزالة المقال من المحفوظات'**
  String get bookmarkRemoved;

  /// No description provided for @saveArticle.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المقال'**
  String get saveArticle;

  /// No description provided for @removeBookmark.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المحفوظات'**
  String get removeBookmark;

  /// No description provided for @articleNotFound.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر العثور على المقال'**
  String get articleNotFound;

  /// No description provided for @relatedArticles.
  ///
  /// In ar, this message translates to:
  /// **'مقالات ذات صلة'**
  String get relatedArticles;

  /// No description provided for @fontScaleTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجم خط القراءة'**
  String get fontScaleTitle;

  /// No description provided for @fontSmall.
  ///
  /// In ar, this message translates to:
  /// **'صغير'**
  String get fontSmall;

  /// No description provided for @fontMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get fontMedium;

  /// No description provided for @fontLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير'**
  String get fontLarge;

  /// No description provided for @fontExtraLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير جداً'**
  String get fontExtraLarge;

  /// No description provided for @fontPreviewText.
  ///
  /// In ar, this message translates to:
  /// **'هذا نص تجريبي لمعاينة حجم خط القراءة في منصة أفق.'**
  String get fontPreviewText;

  /// No description provided for @shareArticle.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الخبر'**
  String get shareArticle;

  /// No description provided for @openInBrowser.
  ///
  /// In ar, this message translates to:
  /// **'فتح في المتصفح'**
  String get openInBrowser;

  /// No description provided for @openImage.
  ///
  /// In ar, this message translates to:
  /// **'فتح الصورة'**
  String get openImage;

  /// No description provided for @adLabel.
  ///
  /// In ar, this message translates to:
  /// **'إعلان'**
  String get adLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In ar, this message translates to:
  /// **'المظهر والقراءة'**
  String get appearanceSection;

  /// No description provided for @themeModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get themeModeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي حسب النظام'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'الوضع النهاري'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get themeDark;

  /// No description provided for @fontScaleSection.
  ///
  /// In ar, this message translates to:
  /// **'حجم خط المقالات'**
  String get fontScaleSection;

  /// No description provided for @languageSection.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languageSection;

  /// No description provided for @languageLabel.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get languageLabel;

  /// No description provided for @notificationsSection.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات والبيانات'**
  String get notificationsSection;

  /// No description provided for @breakingNotificationsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الأخبار العاجلة'**
  String get breakingNotificationsLabel;

  /// No description provided for @dataSection.
  ///
  /// In ar, this message translates to:
  /// **'البيانات والتخزين'**
  String get dataSection;

  /// No description provided for @clearCacheLabel.
  ///
  /// In ar, this message translates to:
  /// **'مسح الذاكرة المؤقتة'**
  String get clearCacheLabel;

  /// No description provided for @cacheClearedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم مسح الذاكرة المؤقتة بنجاح، المحفوظات سليمة.'**
  String get cacheClearedMessage;

  /// No description provided for @aboutSection.
  ///
  /// In ar, this message translates to:
  /// **'منصة أفق'**
  String get aboutSection;

  /// No description provided for @aboutUs.
  ///
  /// In ar, this message translates to:
  /// **'من نحن وهيئة التحرير'**
  String get aboutUs;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية وشروط الاستخدام'**
  String get privacyPolicy;

  /// No description provided for @adsPrivacyOptions.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات خصوصية الإعلانات'**
  String get adsPrivacyOptions;

  /// No description provided for @versionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String versionLabel(String version);

  /// No description provided for @notificationsEnabled.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل إشعارات الأخبار العاجلة'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف إشعارات الأخبار العاجلة'**
  String get notificationsDisabled;

  /// No description provided for @aboutTitle.
  ///
  /// In ar, this message translates to:
  /// **'من نحن وهيئة التحرير'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In ar, this message translates to:
  /// **'منصة أفق مؤسسة إخبارية عربية مستقلة تسعى لتقديم أخبار دقيقة وتقارير معمقة بسرعة ومهنية، مع الالتزام بأخلاقيات الصحافة واحترام عقل القارئ ووقته.'**
  String get aboutBody;

  /// No description provided for @editorialBody.
  ///
  /// In ar, this message translates to:
  /// **'تعمل هيئة التحرير وفق سياسة تحريرية صارمة للتحقق من المعلومات قبل النشر، وتفصل بوضوح بين الخبر والرأي والإعلان.'**
  String get editorialBody;

  /// No description provided for @contactTitle.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contactTitle;

  /// No description provided for @emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailLabel;

  /// No description provided for @websiteLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الإلكتروني'**
  String get websiteLabel;

  /// No description provided for @categoriesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get categoriesTitle;

  /// No description provided for @articlesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مقال'**
  String articlesCount(int count);

  /// No description provided for @notificationChannelName.
  ///
  /// In ar, this message translates to:
  /// **'الأخبار العاجلة - منصة أفق'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات فورية عند وقوع أحداث عاجلة'**
  String get notificationChannelDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
