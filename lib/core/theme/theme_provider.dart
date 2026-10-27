import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/preferences_service.dart';

/// إدارة وضع المظهر (تلقائي / نهاري / ليلي).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final PreferencesService prefs = ref.watch(preferencesServiceProvider);
    final String? saved = prefs.getString(PrefKeys.themeMode);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    final PreferencesService prefs = ref.read(preferencesServiceProvider);
    await prefs.setString(PrefKeys.themeMode, mode.name);
    state = mode;
  }
}

final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// الدرجات الأربع لمقياس خط قراءة المقال.
abstract final class ArticleFontScales {
  const ArticleFontScales._();

  static const double small = 0.90;
  static const double medium = 1.00;
  static const double large = 1.15;
  static const double extraLarge = 1.30;

  static const List<double> values = <double>[small, medium, large, extraLarge];
}

/// إدارة مقياس خط قراءة المقال وحفظه محلياً.
class ArticleFontScaleNotifier extends Notifier<double> {
  @override
  double build() {
    final PreferencesService prefs = ref.watch(preferencesServiceProvider);
    final double? saved = prefs.getDouble(PrefKeys.articleFontScale);
    if (saved != null && ArticleFontScales.values.contains(saved)) {
      return saved;
    }
    return ArticleFontScales.medium;
  }

  Future<void> setScale(double scale) async {
    if (!ArticleFontScales.values.contains(scale)) {
      return;
    }
    final PreferencesService prefs = ref.read(preferencesServiceProvider);
    await prefs.setDouble(PrefKeys.articleFontScale, scale);
    state = scale;
  }
}

final NotifierProvider<ArticleFontScaleNotifier, double>
    articleFontScaleProvider =
    NotifierProvider<ArticleFontScaleNotifier, double>(
        ArticleFontScaleNotifier.new);
