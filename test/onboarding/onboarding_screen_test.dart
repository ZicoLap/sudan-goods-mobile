import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/onboarding/pages/onboarding_screen.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  group('OnboardingScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders first onboarding page in English', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Sudan Goods'), findsOneWidget);
      expect(
        find.text(
          'Discover authentic Sudanese products from trusted local stores.',
        ),
        findsOneWidget,
      );
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
      expect(find.byType(IllustrationBackdropBlob), findsOneWidget);
    });

    testWidgets('renders localized content in Arabic', (tester) async {
      await tester.pumpWidget(
        _wrap(const OnboardingScreen(), locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      expect(find.text('مرحباً بك في سلع السودان'), findsOneWidget);
      expect(find.text('تخطي'), findsOneWidget);
    });

    testWidgets('skip marks onboarding complete and navigates', (tester) async {
      final service = OnboardingPersistenceService();

      await tester.pumpWidget(
        _wrap(
          OnboardingScreen(
            persistenceService: service,
            nextScreen: const Scaffold(body: Text('Done')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(await service.getHasSeenOnboarding(), isTrue);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('get started on last page completes onboarding', (tester) async {
      final service = OnboardingPersistenceService();

      await tester.pumpWidget(
        _wrap(
          OnboardingScreen(
            persistenceService: service,
            nextScreen: const Scaffold(body: Text('Auth Placeholder')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 450));
      }
      await tester.tap(find.text('Get started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(await service.getHasSeenOnboarding(), isTrue);
      expect(find.text('Auth Placeholder'), findsOneWidget);
    });

    testWidgets('uses RTL layout direction for Arabic locale', (tester) async {
      await tester.pumpWidget(
        _wrap(const OnboardingScreen(), locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      final direction = Directionality.of(
        tester.element(find.byType(OnboardingScreen)),
      );
      expect(direction, TextDirection.rtl);
    });
  });
}
