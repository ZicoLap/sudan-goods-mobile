import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudan_goods/l10n/supported_app_locales.dart';

/// Service responsible for persisting and retrieving the user's selected
/// application language. Kept small and testable.
class LocalePersistenceService {
  static const String _keyLanguageCode = 'app_language_code';

  /// Returns a supported language code (e.g. `en`, `ar`), or `null` if none or
  /// invalid/corrupt data is stored.
  Future<String?> getSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLanguageCode);
    if (!SupportedAppLocales.isSupported(raw)) {
      if (raw != null && raw.isNotEmpty) {
        await prefs.remove(_keyLanguageCode);
      }
      return null;
    }
    return raw;
  }

  /// Persists the provided language code when it is supported.
  Future<void> saveLanguageCode(String code) async {
    if (!SupportedAppLocales.isSupported(code)) {
      throw ArgumentError.value(code, 'code', 'Unsupported language code');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, code);
  }

  /// Clears any saved language selection.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLanguageCode);
  }
}
