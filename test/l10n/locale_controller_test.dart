import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';

void main() {
  group('LocaleController', () {
    late LocalePersistenceService persistence;
    late LocaleController controller;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      persistence = LocalePersistenceService();
      controller = LocaleController(persistence);
    });

    test('loadSavedLocale sets locale from persistence', () async {
      await persistence.saveLanguageCode('ar');
      await controller.loadSavedLocale();
      expect(controller.locale.value?.languageCode, 'ar');
    });

    test('loadSavedLocale leaves locale null when nothing saved', () async {
      await controller.loadSavedLocale();
      expect(controller.locale.value, isNull);
    });

    test('setLanguageCode updates locale and persists', () async {
      await controller.setLanguageCode('en');
      expect(controller.locale.value?.languageCode, 'en');
      expect(await persistence.getSavedLanguageCode(), 'en');
    });

    test('setLanguageCode rejects unsupported codes', () async {
      expect(() => controller.setLanguageCode('de'), throwsArgumentError);
    });

    test('clearSavedLanguage resets locale', () async {
      await controller.setLanguageCode('en');
      await controller.clearSavedLanguage();
      expect(controller.locale.value, isNull);
      expect(await persistence.getSavedLanguageCode(), isNull);
    });

    test('currentLanguageCode falls back when locale is null', () {
      expect(controller.currentLanguageCode(), 'en');
      expect(controller.currentLanguageCode(fallback: 'ar'), 'ar');
    });
  });
}
