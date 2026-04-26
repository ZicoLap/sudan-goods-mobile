import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/authentication/pages/login_page.dart';
import 'package:sudan_goods/authentication/pages/role_redirect_page.dart';
import 'package:sudan_goods/Home/pages/main_shell.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';

/// Authentication gate that handles:
/// 1. Auth state changes (sign in/out)
/// 2. Role-based access control (customer vs other roles)
/// 3. User profile loading
///
/// Uses Custom Claims first (fast path), then falls back to Firestore check
/// for backward compatibility with legacy users.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  /// Get role from Firebase Auth Custom Claims (JWT token)
  /// Returns null if claims not set yet (legacy users)
  Future<String?> _getRoleFromToken(User user) async {
    try {
      final tokenResult = await user.getIdTokenResult();
      return tokenResult.claims?['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        final uid = user.uid;

        // Check Custom Claims first (fast path - no Firestore read needed)
        // This is the primary RBAC mechanism
        return FutureBuilder<String?>(
          future: _getRoleFromToken(user),
          builder: (context, tokenSnapshot) {
            // If we have custom claims, use them immediately
            if (tokenSnapshot.hasData && tokenSnapshot.data != null) {
              final role = tokenSnapshot.data!;
              return _buildForRole(context, uid, role, useFirestore: false);
            }

            // If token check failed or no claims, fall back to Firestore
            // This handles legacy users registered before Custom Claims were implemented
            return StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .snapshots(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final data = userSnapshot.data!.data() as Map<String, dynamic>?;
                final role = data?['role'];

                // Doc not yet written - Cloud Function still processing
                if (role == null) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                return _buildForRole(context, uid, role, useFirestore: true);
              },
            );
          },
        );
      },
    );
  }

  /// Build the appropriate page based on user role
  Widget _buildForRole(
    BuildContext context,
    String uid,
    String role, {
    required bool useFirestore,
  }) {
    switch (role) {
      case 'customer':
        return _buildCustomerShell(context, uid);
      case 'storeOwner':
        return const RoleRedirectPage(role: 'storeOwner');
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
