import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_manager.dart';

/// تهيئة خدمة الإعلانات بعد موافقة UMP دون حجب إقلاع الواجهة.
class AdService {
  AdService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    if (Platform.environment.containsKey('FLUTTER_TEST') ||
        !Platform.isAndroid) {
      return;
    }
    try {
      final bool canRequest = await ConsentManager.gatherConsent();
      if (!canRequest) {
        debugPrint('AdMob: ads not allowed by consent state.');
        return;
      }
      await MobileAds.instance.initialize();
      _initialized = true;
    } on Object catch (error) {
      // لا يُسقط التطبيق أبداً بسبب فشل تهيئة الإعلانات.
      debugPrint('AdMob initialization failed: $error');
    }
  }
}
