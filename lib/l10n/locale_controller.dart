import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';
import 'package:sudan_goods/l10n/supported_app_locales.dart';

/// Controller responsible for managing the current application [Locale].
/// Uses a ValueNotifier to notify listeners when the locale changes.
/// Persistence is delegated to [LocalePersistenceService].
class LocaleController {
  LocaleController(this._persistenceService);

  final LocalePersistenceService _persistenceService;

  /// The current locale value; when null, the system locale is used.
  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  /// Loads a saved language code from persistence and updates [locale].
  Future<void> loadSavedLocale() async {
    final code = await _persistenceService.getSavedLanguageCode();
    locale.value = code == null ? null : Locale(code);
  }

  /// Sets the language using its code (e.g., 'en', 'ar') and persists it.
  Future<void> setLanguageCode(String code) async {
    if (!SupportedAppLocales.isSupported(code)) {
      throw ArgumentError.value(code, 'code', 'Unsupported language code');
    }
    await _persistenceService.saveLanguageCode(code);
    locale.value = Locale(code);
  }

  /// Clears any saved language and reverts to system default.
  Future<void> clearSavedLanguage() async {
    await _persistenceService.clear();
    locale.value = null;
  }

  /// Returns the current language code or the provided [fallback] if null.
  String currentLanguageCode({String fallback = 'en'}) =>
      locale.value?.languageCode ?? fallback;
}
