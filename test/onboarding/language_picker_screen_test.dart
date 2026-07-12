import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';
import 'package:sudan_goods/onboarding/language_picker_screen.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';

void main() {
  group('LanguagePickerScreen layout', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders without overflow on small phone size', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        Provider<LocaleController>(
          create: (_) => LocaleController(LocalePersistenceService()),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LanguagePickerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LanguagePickerScreen), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
      expect(find.byType(IllustrationBackdropBlob), findsOneWidget);
    });

    testWidgets('illustration assets are registered', (tester) async {
      expect(OnboardingAssets.languageWelcome, isNotEmpty);
      expect(OnboardingAssets.welcome, isNotEmpty);
      expect(OnboardingAssets.order, isNotEmpty);
      expect(OnboardingAssets.discover, isNotEmpty);
      expect(OnboardingAssets.start, isNotEmpty);
    });
  });
}
