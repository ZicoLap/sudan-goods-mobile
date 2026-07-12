import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';

void main() {
  group('LocalePersistenceService', () {
    late LocalePersistenceService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = LocalePersistenceService();
    });

    test('returns null when no language is saved', () async {
      expect(await service.getSavedLanguageCode(), isNull);
    });

    test('persists and reads supported language codes', () async {
      await service.saveLanguageCode('en');
      expect(await service.getSavedLanguageCode(), 'en');

      await service.saveLanguageCode('ar');
      expect(await service.getSavedLanguageCode(), 'ar');
    });

    test('rejects unsupported language codes on save', () async {
      expect(() => service.saveLanguageCode('fr'), throwsArgumentError);
    });

    test('clears invalid stored language codes', () async {
      SharedPreferences.setMockInitialValues({
        'app_language_code': 'invalid',
      });
      service = LocalePersistenceService();

      expect(await service.getSavedLanguageCode(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language_code'), isNull);
    });

    test('clear removes saved language', () async {
      await service.saveLanguageCode('en');
      await service.clear();
      expect(await service.getSavedLanguageCode(), isNull);
    });
  });
}
