// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Oufoq Platform';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navBookmarks => 'Bookmarks';

  @override
  String get navSettings => 'Settings';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get clear => 'Clear';

  @override
  String get seeAll => 'See all';

  @override
  String get loading => 'Loading…';

  @override
  String get errorNoInternet =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorServer =>
      'The server is currently unreachable. Please try again later.';

  @override
  String get errorUnknown => 'An unexpected error occurred. Please try again.';

  @override
  String get errorEmptyCache => 'No saved data yet.';

  @override
  String get errorViewTitle => 'Something went wrong';

  @override
  String get errorViewBody =>
      'The content could not be loaded. You can try again.';

  @override
  String get emptyDefaultTitle => 'Nothing here yet';

  @override
  String get emptyDefaultBody =>
      'The latest news will appear here as soon as it is available.';

  @override
  String get justNow => 'Now';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String readingTimeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min read',
      one: '1 min read',
    );
    return '$_temp0';
  }

  @override
  String get breakingLabel => 'Breaking';

  @override
  String get featuredSection => 'Top stories';

  @override
  String get latestNews => 'Latest news';

  @override
  String get categoryAllChip => 'All';

  @override
  String get offlineBanner =>
      'You are offline — showing the latest saved content';

  @override
  String get searchButtonLabel => 'Search';

  @override
  String get searchHint => 'Search the news…';

  @override
  String get searchHistoryTitle => 'Recent searches';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get searchEmptyTitle => 'No matching results';

  @override
  String get searchEmptyBody =>
      'Try different keywords to find what you are looking for.';

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String get bookmarksEmptyTitle => 'No saved articles';

  @override
  String get bookmarksEmptyBody =>
      'Save articles you care about to read later offline.';

  @override
  String get bookmarkAdded => 'Article saved to bookmarks';

  @override
  String get bookmarkRemoved => 'Article removed from bookmarks';

  @override
  String get saveArticle => 'Save article';

  @override
  String get removeBookmark => 'Remove from bookmarks';

  @override
  String get articleNotFound => 'Article not found';

  @override
  String get relatedArticles => 'Related articles';

  @override
  String get fontScaleTitle => 'Reading font size';

  @override
  String get fontSmall => 'Small';

  @override
  String get fontMedium => 'Medium';

  @override
  String get fontLarge => 'Large';

  @override
  String get fontExtraLarge => 'Extra large';

  @override
  String get fontPreviewText =>
      'This is a sample text to preview the reading font size on Oufoq Platform.';

  @override
  String get shareArticle => 'Share article';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String get openImage => 'Open image';

  @override
  String get adLabel => 'Ad';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance & reading';

  @override
  String get themeModeLabel => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get fontScaleSection => 'Article font size';

  @override
  String get languageSection => 'Language';

  @override
  String get languageLabel => 'App language';

  @override
  String get notificationsSection => 'Notifications & data';

  @override
  String get breakingNotificationsLabel => 'Breaking news notifications';

  @override
  String get dataSection => 'Data & storage';

  @override
  String get clearCacheLabel => 'Clear cached data';

  @override
  String get clearCacheSubtitle =>
      'Deletes cached images and news while keeping your bookmarks.';

  @override
  String get cacheClearedMessage =>
      'Cache cleared successfully. Your bookmarks are safe.';

  @override
  String get aboutSection => 'Oufoq Platform';

  @override
  String get aboutUs => 'About us & editorial board';

  @override
  String get contactUs => 'Contact us';

  @override
  String get privacyPolicy => 'Privacy policy & terms of use';

  @override
  String get adsPrivacyOptions => 'Ads privacy options';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutTitle => 'About us & editorial board';

  @override
  String get aboutBody =>
      'Oufoq Platform is an independent Arabic news organisation committed to delivering accurate news and in-depth reports with speed and professionalism, while respecting journalistic ethics and the reader\'s time.';

  @override
  String get editorialBody =>
      'The editorial team follows a strict fact-checking policy before publication and clearly separates news, opinion and advertising.';

  @override
  String get contactTitle => 'Contact us';

  @override
  String get emailLabel => 'Email';

  @override
  String get websiteLabel => 'Website';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get notificationChannelName => 'Breaking news - Oufoq Platform';

  @override
  String get notificationChannelDescription =>
      'Instant alerts for breaking events';
}
