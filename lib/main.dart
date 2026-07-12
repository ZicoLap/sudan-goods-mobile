import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/checkout/controller/checkout_controller.dart';
import 'package:sudan_goods/checkout/services/checkout_service.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';
import 'package:sudan_goods/onboarding/app_start_gate.dart';
import 'package:sudan_goods/Home/controller/store_filter_controller.dart';
import 'package:sudan_goods/follow/presentation/controllers/follow_controller.dart';
import 'package:sudan_goods/follow/presentation/wiring/follow_wiring_example.dart';

import 'package:sudan_goods/contact/controllers/contact_controller.dart';
import 'package:sudan_goods/about/controllers/about_us_controller.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// import 'package:cloud_functions/cloud_functions.dart';

import 'firebase_options.dart';

/// Stripe publishable key — safe to include in client code.
/// Replace with your real key from https://dashboard.stripe.com/apikeys
const String _stripePublishableKey =
    'pk_test_51TQTIJC8L35W2jp3YMbx20NJDIfrqzlNFUKARDRzXvZhgMvHXZc2vCWr5au3Zbd7lHHOYufaiO9bXOuMby1DMaAh00PUjXquah';

/// Entry point of the Sudan Goods application.
///
/// Ensures Flutter bindings are initialized, initializes Firebase with
/// platform-specific options, and bootstraps the widget tree with providers.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = _stripePublishableKey;
  // We intentionally provide a ChangeNotifier (FollowController) using ProxyProvider,
  // and we manage disposal manually. Disable Provider's debug check for this case.
  Provider.debugCheckInvalidValueType = null;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print("Firebase initialized successfully");
  }

  // Initialize Firebase App Check
  // Use debug providers only in debug builds; production must use
  // Play Integrity / App Attest to prevent abuse of backend resources.
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // FollowController depends on the authenticated user. It will be created
        // once the user has been loaded in UserProvider.
        ProxyProvider<UserProvider, FollowController?>(
          update: (_, userProvider, previous) {
            if (!userProvider.isUserLoaded) {
              return previous; // user not loaded yet
            }
            // Reuse previous instance if available; otherwise create one.
            if (previous != null) return previous;
            final uid = userProvider.currentUser.uid;
            return makeFollowControllerForUid(uid);
          },
          dispose: (_, value) => value?.dispose(),
        ),
        ChangeNotifierProvider(
          create: (_) => CheckoutController(checkoutService: CheckoutService()),
        ),
        ChangeNotifierProvider(create: (_) => StoreFilterController()),
        ChangeNotifierProvider(create: (_) => ContactController()),
        ChangeNotifierProvider(create: (_) => AboutUsController()),
        Provider<LocaleController>(
          create:
              (_) =>
                  LocaleController(LocalePersistenceService())
                    ..loadSavedLocale(),
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
    final localeController = Provider.of<LocaleController>(
      context,
      listen: false,
    );
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          onGenerateTitle:
              (context) =>
                  AppLocalizations.of(context)?.appTitle ?? 'Sudan Goods',
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
          home:
              AppStartGate(), // App start gate decides Language → Onboarding → Auth
        );
      },
    );
  }
}
