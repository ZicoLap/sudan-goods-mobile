import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/authentication/account/email_verification_page.dart';
import 'package:sudan_goods/authentication/login/login_page.dart';
import 'package:sudan_goods/authentication/role/role_redirect_page.dart';
import 'package:sudan_goods/authentication/role/role_resolver.dart';
import 'package:sudan_goods/core/shell/main_shell.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';

/// Authentication gate that handles:
/// 1. Auth state changes (sign in/out)
/// 2. Role-based access control (customer vs other roles)
/// 3. User profile loading
///
/// Uses Custom Claims first (fast path), then falls back to Firestore check
/// for backward compatibility with legacy users.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Capture the provider outside the async listener so the closure does not
    // hold a BuildContext across async gaps.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // User signed out: clear cached profile so stale data is not shown
        // on the next sign-in.
        userProvider.clear();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleResolver = RoleResolver();
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) return const LoginPage();

        final user = snapshot.data!;

        // Block the session until the user verifies their email address.
        if (!user.emailVerified) {
          return const EmailVerificationPage();
        }

        return FutureBuilder<String?>(
          future: roleResolver.resolve(user),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasError) {
              return _buildErrorState(context, roleSnapshot.error.toString());
            }

            final role = roleSnapshot.data;

            // Doc not yet written - Cloud Function still processing
            if (role == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return _buildForRole(context, user.uid, role);
          },
        );
      },
    );
  }

  /// Build the appropriate page based on user role
  Widget _buildForRole(BuildContext context, String uid, String role) {
    switch (role) {
      case 'customer':
        return _buildCustomerShell(context, uid);
      case 'vendor':
        return const RoleRedirectPage(role: 'vendor');
      case 'admin':
        return const RoleRedirectPage(role: 'admin');
      default:
        // Unknown role - could be data corruption or new role type
        return const UnknownRolePage();
    }
  }

  /// Build MainShell for customer users with proper user loading
  Widget _buildCustomerShell(BuildContext context, String uid) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // If already loaded for this uid, go straight to MainShell
    if (userProvider.isUserLoaded) {
      try {
        if (userProvider.currentUser.uid == uid) {
          return const MainShell();
        }
      } catch (_) {
        // fall through to fetch
      }
    }

    return FutureBuilder<void>(
      future: userProvider.fetchUser(uid),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return _buildErrorState(context, snap.error.toString());
        }

        return const MainShell();
      },
    );
  }

  /// Build error state with retry options
  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load user profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Trigger rebuild by replacing with self
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
