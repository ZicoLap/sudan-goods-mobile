import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/onboarding/language_picker_screen.dart';
import 'package:sudan_goods/onboarding/onboarding_screen.dart';
import 'package:sudan_goods/authentication/auth_gate_page.dart';

class AppStartGate extends StatelessWidget {
  const AppStartGate({super.key});

  Future<_StartState> _load() async {
    final localeSvc = LocalePersistenceService();
    final onbSvc = OnboardingPersistenceService();
    final savedCode = await localeSvc.getSavedLanguageCode();
    final hasSeen = await onbSvc.getHasSeenOnboarding();
    return _StartState(savedCode, hasSeen);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartState>(
      future: _load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final state = snap.data!;
        if (state.languageCode == null || state.languageCode!.isEmpty) {
          return const LanguagePickerScreen();
        }
        if (!state.hasSeenOnboarding) {
          return const OnboardingScreen();
        }
        return const AuthGate();
      },
    );
  }
}

class _StartState {
  final String? languageCode;
  final bool hasSeenOnboarding;
  _StartState(this.languageCode, this.hasSeenOnboarding);
}
