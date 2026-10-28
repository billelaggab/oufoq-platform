import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/storage/app_database.dart';
import 'core/storage/preferences_service.dart';
import 'features/ads/data/ad_service.dart';
import 'features/notifications/data/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة بيانات صيغ التواريخ لكل اللغات (ar/en/fr).
  await initializeDateFormatting();

  // التهيئة المحلية قبل الإقلاع.
  final PreferencesService preferences = await PreferencesService.create();
  final AppDatabase database = await AppDatabase.open();

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const OufoqApp(),
    ),
  );

  // خدمات غير معطِّلة للإقلاع تُشغَّل بعد أول إطار.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _bootstrapBackgroundServices(preferences);
  });
}

Future<void> _bootstrapBackgroundServices(PreferencesService preferences) async {
  // نصوص القناة تأتي من طبقة الترجمة (العربية هي اللغة النشطة في الإصدار 1.0).
  final AppLocalizations l10n =
      lookupAppLocalizations(const Locale('ar'));
  final PushNotificationService push = PushNotificationService.instance;
  push.onArticleTapped =
      (int postId) => appRouter.push(RouteNames.articlePath(postId));

  // AdMob وFCM مستقلان: نُهيئهما بالتوازي حتى لا تؤخر مهلة موافقة UMP
  // تهيئة الإشعارات (أو العكس).
  await Future.wait<void>(<Future<void>>[
    AdService.initialize(),
    _initializeNotifications(push, l10n, preferences),
  ]);
}

Future<void> _initializeNotifications(
  PushNotificationService push,
  AppLocalizations l10n,
  PreferencesService preferences,
) async {
  await push.initialize(
    channelName: l10n.notificationChannelName,
    channelDescription: l10n.notificationChannelDescription,
  );

  final bool notificationsEnabled =
      preferences.getBool(PrefKeys.notificationsEnabled) ?? true;
  if (notificationsEnabled) {
    final String localeCode =
        preferences.getString(PrefKeys.locale) ?? 'ar';
    await push.requestPermissionAndSubscribe(localeCode);
  }
}
