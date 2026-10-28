import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_manager.dart';

/// تهيئة خدمة الإعلانات بعد موافقة UMP دون حجب إقلاع الواجهة.
class AdService {
  AdService._();

  static bool _started = false;
  static bool _ready = false;
  static Future<void>? _initialization;

  /// هل اكتملت تهيئة MobileAds بنجاح؟ وحدات الإعلانات تنتظر هذه القيمة
  /// قبل محاولة التحميل لتفادي فشل «SDK not initialized».
  static bool get isReady => _ready;

  /// تهيئة واحدة مشتركة؛ كل مستدعٍ ينتظر نفس العملية بدل تكرارها.
  static Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  static Future<void> _initialize() async {
    if (_started) {
      return;
    }
    _started = true;
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
      _ready = true;
    } on Object catch (error) {
      // لا يُسقط التطبيق أبداً بسبب فشل تهيئة الإعلانات.
      debugPrint('AdMob initialization failed: $error');
    }
  }
}
