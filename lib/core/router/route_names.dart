/// مسارات التطبيق الموحدة للتنقل والروابط العميقة.
abstract final class RouteNames {
  const RouteNames._();

  static const String home = '/';
  static const String categories = '/categories';
  static const String bookmarks = '/bookmarks';
  static const String settings = '/settings';

  static const String search = '/search';
  static const String article = '/article/:id';
  static const String category = '/category/:id';
  static const String about = '/about';
  static const String contact = '/contact';

  static String articlePath(int id) => '/article/$id';
  static String categoryPath(int id) => '/category/$id';
}
