import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for persisting and retrieving the user's selected
/// application language. Kept small and testable.
class LocalePersistenceService {
  static const String _keyLanguageCode = 'app_language_code';

  /// Returns the persisted language code (e.g., 'en', 'ar'), or null if none.
  Future<String?> getSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguageCode);
  }

  /// Persists the provided language code.
  Future<void> saveLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, code);
  }

  /// Clears any saved language selection.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLanguageCode);
  }
}
