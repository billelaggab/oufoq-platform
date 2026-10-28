import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مفاتيح التخزين المحلي للإعدادات الخفيفة.
abstract final class PrefKeys {
  const PrefKeys._();

  static const String themeMode = 'pref_theme_mode';
  static const String locale = 'pref_locale';
  static const String articleFontScale = 'pref_article_font_scale';
  static const String notificationsEnabled = 'pref_notifications_enabled';
  static const String searchHistory = 'pref_search_history';
  static const String appOpenAdLastShown = 'pref_app_open_ad_last_shown';
  static const String interstitialAdLastShown =
      'pref_interstitial_ad_last_shown';
}

/// غلاف نظيف حول [SharedPreferences].
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  double? getDouble(String key) => _prefs.getDouble(key);

  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  List<String> getStringList(String key) => _prefs.getStringList(key) ?? const <String>[];

  Future<void> setStringList(String key, List<String> values) =>
      _prefs.setStringList(key, values);

  Future<void> remove(String key) => _prefs.remove(key);
}

/// مزوّد Riverpod يُحقن بنسخة مهيأة في `main()`.
final Provider<PreferencesService> preferencesServiceProvider =
    Provider<PreferencesService>((Ref ref) {
  throw UnimplementedError(
    'preferencesServiceProvider يجب أن يُحقن في ProviderScope داخل main()',
  );
});
