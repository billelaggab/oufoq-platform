/// ثوابت التطبيق العامة لمنصة أفق.
abstract final class AppConstants {
  const AppConstants._();

  /// معرّف الحزمة الرسمي للتطبيق.
  static const String packageName = 'com.oufoq.platform';

  /// اسم التطبيق.
  static const String appName = 'منصة أفق';

  /// رقم الإصدار الظاهر في شاشة الإعدادات.
  static const String appVersion = '1.0.0';

  /// عدد المقالات الافتراضي في كل صفحة من WordPress REST API.
  static const int defaultPageSize = 10;

  /// عدد المقالات في السلايدر الرئيسي.
  static const int featuredPostsLimit = 5;

  /// عدد الأخبار العاجلة.
  static const int breakingPostsLimit = 5;

  /// عدد المقالات ذات الصلة.
  static const int relatedPostsLimit = 4;

  /// أقصى عدد لكلمات البحث المحفوظة محلياً.
  static const int maxSearchHistory = 10;

  /// اسم قاعدة بيانات القراءة أوفلاين.
  static const String offlineDatabaseName = 'oufoq_offline.db';

  /// اسم جدول المقالات المحفوظة.
  static const String bookmarksTable = 'bookmarked_articles';

  /// معرّف قناة إشعارات الأخبار العاجلة.
  static const String breakingChannelId = 'oufoq_breaking_news_channel';

  /// سرعة القراءة العربية (كلمة/دقيقة) لحساب وقت القراءة.
  static const int arabicReadingWordsPerMinute = 180;

  /// مهلة الاتصال بالشبكة.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// مهلة استقبال البيانات.
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// مدة صلاحية الكاش الشبكي عند انقطاع الإنترنت.
  static const Duration cacheMaxStale = Duration(days: 7);
}
