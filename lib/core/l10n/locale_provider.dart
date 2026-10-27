import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/feature_flags.dart';
import '../storage/preferences_service.dart';

/// إدارة اللغة النشطة مع حفظها محلياً والتحقق من كونها مفعّلة.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final PreferencesService prefs = ref.watch(preferencesServiceProvider);
    final String? savedCode = prefs.getString(PrefKeys.locale);
    if (savedCode != null) {
      final Iterable<Locale> match = LocaleConfig.activeLocales
          .where((Locale l) => l.languageCode == savedCode);
      if (match.isNotEmpty) {
        return match.first;
      }
    }
    return LocaleConfig.defaultLocale;
  }

  Future<void> setLocale(Locale locale) async {
    if (!LocaleConfig.activeLocales.contains(locale)) {
      return;
    }
    final PreferencesService prefs = ref.read(preferencesServiceProvider);
    await prefs.setString(PrefKeys.locale, locale.languageCode);
    state = locale;
  }
}

final NotifierProvider<LocaleNotifier, Locale> localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
