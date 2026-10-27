import 'dart:io';

import 'package:flutter/foundation.dart';

/// إدارة معرفات وحدات AdMob مع حماية صارمة أثناء التطوير والاختبارات.
abstract final class AdUnitIds {
  const AdUnitIds._();

  // معرفات الاختبار الرسمية من Google لنظام أندرويد.
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _testNativeAndroid =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppOpenAndroid =
      'ca-app-pub-3940256099942544/9257395921';

  // معرفات الإنتاج تُحقن وقت بناء المتجر عبر --dart-define.
  static const String _prodBannerAndroid =
      String.fromEnvironment('ADMOB_BANNER_ID');
  static const String _prodNativeAndroid =
      String.fromEnvironment('ADMOB_NATIVE_ID');
  static const String _prodInterstitialAndroid =
      String.fromEnvironment('ADMOB_INTERSTITIAL_ID');
  static const String _prodAppOpenAndroid =
      String.fromEnvironment('ADMOB_APP_OPEN_ID');

  /// أثناء اختبارات الوحدات أو على منصات غير أندرويد => تخطٍّ آمن.
  static bool get _shouldSkip =>
      Platform.environment.containsKey('FLUTTER_TEST') || !Platform.isAndroid;

  static String _resolve(String testId, String prodId) {
    if (_shouldSkip) {
      return '';
    }
    if (!kReleaseMode || prodId.isEmpty) {
      return testId;
    }
    return prodId;
  }

  static String get banner =>
      _resolve(_testBannerAndroid, _prodBannerAndroid);
  static String get native =>
      _resolve(_testNativeAndroid, _prodNativeAndroid);
  static String get interstitial =>
      _resolve(_testInterstitialAndroid, _prodInterstitialAndroid);
  static String get appOpen =>
      _resolve(_testAppOpenAndroid, _prodAppOpenAndroid);
}
