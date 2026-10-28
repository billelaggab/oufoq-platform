/// قراءة متغيرات البيئة المحقونة وقت البناء عبر `--dart-define`.
///
/// مثال البناء للإنتاج:
/// flutter build appbundle --dart-define=WP_BASE_URL=https://example.com ...
abstract final class EnvConfig {
  const EnvConfig._();

  /// الرابط الجذري لموقع ووردبريس (بدون /wp-json).
  /// القيمة الافتراضية موقع تجريبي عام يعمل بووردبريس لتجربة التطبيق فوراً.
  static const String wpBaseUrl = String.fromEnvironment(
    'WP_BASE_URL',
    defaultValue: 'https://oufoq.com',
  );

  /// البريد الرسمي للتواصل.
  static const String contactEmail = String.fromEnvironment(
    'CONTACT_EMAIL',
    defaultValue: 'editor@oufoq.com',
  );

  /// رابط الموقع الرسمي.
  static const String officialWebsite = String.fromEnvironment(
    'OFFICIAL_WEBSITE',
    defaultValue: 'https://oufoq.com',
  );

  /// رابط سياسة الخصوصية (إلزامي لقبول التطبيقات الإخبارية).
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://oufoq.com/privacy-policy',
  );

  /// معرّف قسم الأخبار العاجلة في ووردبريس (يُضبط من إضافة الجسر إن وُجدت).
  static const int fallbackBreakingCategoryId = int.fromEnvironment(
    'BREAKING_CATEGORY_ID',
    defaultValue: 0,
  );
}
