import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/authentication/auth_gate_page.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/checkout/controller/checkout_controller.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/user/user_provider.dart';

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
    return MaterialApp(
      title: 'Sudan Goods',
      theme: AppTheme.lightTheme,
      home: AuthGate(), // We'll create this next
    );
  }
}
