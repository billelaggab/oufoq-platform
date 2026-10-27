import 'package:flutter/foundation.dart';

/// إعدادات الإعلانات القابلة للتحكم عن بُعد عبر إضافة Oufoq Bridge.
@immutable
class AdConfig {
  const AdConfig({
    this.enabled = true,
    this.bannerEnabled = true,
    this.nativeEnabled = true,
    this.nativeInterval = 5,
    this.interstitialEnabled = true,
    this.interstitialArticleThreshold = 4,
    this.interstitialCooldownMinutes = 3,
    this.appOpenEnabled = false,
    this.breakingCategoryId = 0,
  });

  /// مفتاح إيقاف شامل.
  final bool enabled;
  final bool bannerEnabled;
  final bool nativeEnabled;

  /// إعلان مدمج بعد كل هذا العدد من المقالات.
  final int nativeInterval;
  final bool interstitialEnabled;

  /// عدد المقالات المقروءة قبل أول إعلان بيني.
  final int interstitialArticleThreshold;

  /// الفاصل الزمني الأدنى بين إعلانين بينيين (دقيقة).
  final int interstitialCooldownMinutes;
  final bool appOpenEnabled;

  /// معرّف قسم الأخبار العاجلة من الإعداد البعيد.
  final int breakingCategoryId;

  static const AdConfig safeDefaults = AdConfig();

  factory AdConfig.fromRemoteJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? ads =
        json['ads'] is Map<String, dynamic> ? json['ads'] as Map<String, dynamic> : null;
    if (ads == null) {
      return safeDefaults;
    }
    bool asBool(String key, bool fallback) =>
        ads[key] is bool ? ads[key] as bool : fallback;
    int asInt(String key, int fallback) =>
        ads[key] is int ? ads[key] as int : int.tryParse('${ads[key]}') ?? fallback;

    return AdConfig(
      enabled: asBool('enabled', true),
      bannerEnabled: asBool('banner_enabled', true),
      nativeEnabled: asBool('native_enabled', true),
      nativeInterval: asInt('native_interval', 5),
      interstitialEnabled: asBool('interstitial_enabled', true),
      interstitialArticleThreshold:
          asInt('interstitial_article_threshold', 4),
      interstitialCooldownMinutes:
          asInt('interstitial_cooldown_minutes', 3),
      appOpenEnabled: asBool('app_open_enabled', false),
      breakingCategoryId:
          json['breaking_category_id'] is int ? json['breaking_category_id'] as int : 0,
    );
  }
}
