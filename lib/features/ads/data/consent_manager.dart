import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// إدارة موافقة الخصوصية الأوروبية عبر Google UMP SDK.
class ConsentManager {
  ConsentManager._();

  static final ConsentInformation _information =
      ConsentInformation.instance;

  /// فحص حالة الموافقة وعرض النموذج إن لزم جغرافياً.
  static Future<bool> gatherConsent() async {
    if (_skipPlatform) {
      return true;
    }
    final Completer<bool> completer = Completer<bool>();
    try {
      _information.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired(
                (FormError? _) {});
          } on Object catch (error) {
            debugPrint('UMP form error: $error');
          } finally {
            if (!completer.isCompleted) {
              completer.complete(await canRequestAds());
            }
          }
        },
        (FormError error) {
          debugPrint('UMP consent info error: ${error.message}');
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
      );
    } on Object catch (error) {
      debugPrint('UMP gatherConsent failed: $error');
      return true;
    }
    return completer.future;
  }

  static Future<bool> canRequestAds() async {
    if (_skipPlatform) {
      return true;
    }
    try {
      return await _information.canRequestAds();
    } on Object {
      return true;
    }
  }

  /// هل خيارات خصوصية الإعلانات مطلوبة لهذا المستخدم (مناطق GDPR)؟
  static Future<bool> isPrivacyOptionsRequired() async {
    if (_skipPlatform) {
      return false;
    }
    try {
      final PrivacyOptionsRequirementStatus status =
          await _information.getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } on Object {
      return false;
    }
  }

  static Future<void> showPrivacyOptionsForm() async {
    if (_skipPlatform) {
      return;
    }
    try {
      await ConsentForm.showPrivacyOptionsForm((FormError? _) {});
    } on Object catch (error) {
      debugPrint('UMP privacy form error: $error');
    }
  }

  static bool get _skipPlatform =>
      Platform.environment.containsKey('FLUTTER_TEST') ||
      !Platform.isAndroid;
}
