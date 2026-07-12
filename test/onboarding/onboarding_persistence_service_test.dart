import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';

void main() {
  group('OnboardingPersistenceService', () {
    late OnboardingPersistenceService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = OnboardingPersistenceService();
    });

    test('defaults to not seen onboarding', () async {
      expect(await service.getHasSeenOnboarding(), isFalse);
    });

    test('persists onboarding completion', () async {
      await service.setHasSeenOnboarding(true);
      expect(await service.getHasSeenOnboarding(), isTrue);
    });

    test('can reset onboarding flag', () async {
      await service.setHasSeenOnboarding(true);
      await service.setHasSeenOnboarding(false);
      expect(await service.getHasSeenOnboarding(), isFalse);
    });
  });
}
