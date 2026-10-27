import '../config/env_config.dart';

/// مسارات WordPress REST API v2 وحقول الفلترة المحسّنة.
abstract final class ApiEndpoints {
  const ApiEndpoints._();

  static String get _base => '${EnvConfig.wpBaseUrl}/wp-json/wp/v2';
  static String get oufoqConfig =>
      '${EnvConfig.wpBaseUrl}/wp-json/oufoq/v1/config';

  static String get posts => '$_base/posts';
  static String postById(int id) => '$_base/posts/$id';
  static String get categories => '$_base/categories';

  /// حقول المقالات المقلصة لتوفير 65% من حجم البيانات.
  static const String postFields =
      'id,date,date_gmt,modified,slug,link,title,excerpt,content,categories,tags,featured_media,_links,_embedded,oufoq_featured_image';

  /// حقول قائمة المقالات المضغوطة للقوائم.
  static const String postListFields =
      'id,date,modified,slug,link,title,excerpt,categories,featured_media,_links,_embedded,oufoq_featured_image';

  static const String categoryFields =
      'id,count,description,name,slug,parent';

  static const String embedArgs = 'wp:featuredmedia,wp:term,author';
  static const String embedArgsLite = 'wp:featuredmedia,wp:term';
}
