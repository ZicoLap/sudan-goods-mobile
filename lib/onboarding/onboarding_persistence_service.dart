import 'package:shared_preferences/shared_preferences.dart';

/// Service to persist whether the user has completed onboarding.
class OnboardingPersistenceService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
    
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, value);
  }
}
