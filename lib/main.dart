import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/checkout/controller/checkout_controller.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/user/user_provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';
import 'package:sudan_goods/onboarding/app_start_gate.dart';
import 'package:sudan_goods/Home/controller/store_filter_controller.dart';

import 'firebase_options.dart';

/// Entry point of the Sudan Goods application.
///
/// Ensures Flutter bindings are initialized, initializes Firebase with
/// platform-specific options, and bootstraps the widget tree with providers.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print("Firebase initialized successfully");
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartController()..loadCartsFromFirestore(),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutController()),
        ChangeNotifierProvider(create: (_) => StoreFilterController()),
        Provider<LocaleController>(
          create: (_) => LocaleController(LocalePersistenceService())..loadSavedLocale(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  /// Builds the [MaterialApp] with global theme and the authentication gate.
  Widget build(BuildContext context) {
    final localeController = Provider.of<LocaleController>(context, listen: false);
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            // If user selected a locale, use it.
            if (locale != null) return locale;
            // Otherwise try to match device language code; fallback to English.
            if (deviceLocale != null) {
              for (final l in supportedLocales) {
                if (l.languageCode == deviceLocale.languageCode) return l;
              }
            }
            return const Locale('en');
          },
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const AppStartGate(), // App start gate decides Language → Onboarding → Auth
        );
      },
    );
  }
}
