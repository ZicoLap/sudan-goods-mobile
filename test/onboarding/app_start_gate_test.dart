import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';
import 'package:sudan_goods/onboarding/app_start_gate.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/onboarding/language_picker_screen.dart';
import 'package:sudan_goods/onboarding/onboarding_screen.dart';

class _FakeLocalePersistence extends LocalePersistenceService {
  _FakeLocalePersistence(this._code);

  final String? _code;

  @override
  Future<String?> getSavedLanguageCode() async => _code;
}

class _FakeOnboardingPersistence extends OnboardingPersistenceService {
  _FakeOnboardingPersistence(this._hasSeen);

  final bool _hasSeen;

  @override
  Future<bool> getHasSeenOnboarding() async => _hasSeen;
}

Widget _harness({
  required Widget home,
  Locale locale = const Locale('en'),
}) {
  return Provider<LocaleController>(
    create: (_) => LocaleController(LocalePersistenceService()),
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  group('AppStartGate', () {
    testWidgets('shows language picker when no language is saved', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          home: AppStartGate(
            localePersistence: _FakeLocalePersistence(null),
            onboardingPersistence: _FakeOnboardingPersistence(false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LanguagePickerScreen), findsOneWidget);
    });

    testWidgets('shows language picker when saved language is invalid', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          home: AppStartGate(
            localePersistence: _FakeLocalePersistence('invalid'),
            onboardingPersistence: _FakeOnboardingPersistence(false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LanguagePickerScreen), findsOneWidget);
    });

    testWidgets('shows onboarding when language saved but onboarding not seen', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          home: AppStartGate(
            localePersistence: _FakeLocalePersistence('en'),
            onboardingPersistence: _FakeOnboardingPersistence(false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('routes to post-onboarding screen when onboarding complete', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          home: AppStartGate(
            localePersistence: _FakeLocalePersistence('en'),
            onboardingPersistence: _FakeOnboardingPersistence(true),
            postOnboardingScreen: const Scaffold(body: Text('Post onboarding')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(LanguagePickerScreen), findsNothing);
      expect(find.text('Post onboarding'), findsOneWidget);
    });
  });
}
