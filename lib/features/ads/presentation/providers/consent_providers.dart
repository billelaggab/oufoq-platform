import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/consent_manager.dart';

/// هل خيارات خصوصية الإعلانات مطلوبة لهذا المستخدم (مناطق GDPR)؟
final FutureProvider<bool> privacyOptionsRequiredProvider =
    FutureProvider<bool>((Ref ref) {
  return ConsentManager.isPrivacyOptionsRequired();
});
