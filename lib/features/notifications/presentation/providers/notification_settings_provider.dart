import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../data/push_notification_service.dart';

/// حالة تفعيل إشعارات الأخبار العاجلة.
class NotificationSettingsNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref
            .watch(preferencesServiceProvider)
            .getBool(PrefKeys.notificationsEnabled) ??
        true;
  }

  Future<void> setEnabled(bool enabled) async {
    final PreferencesService prefs = ref.read(preferencesServiceProvider);
    final String languageCode = ref.read(localeProvider).languageCode;
    await prefs.setBool(PrefKeys.notificationsEnabled, value: enabled);
    await PushNotificationService.instance.setNotificationsEnabled(
      enabled: enabled,
      languageCode: languageCode,
    );
    state = enabled;
  }
}

final NotifierProvider<NotificationSettingsNotifier, bool>
    notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, bool>(
        NotificationSettingsNotifier.new);
