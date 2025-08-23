import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/authentication/views/login_page.dart';
import 'package:sudan_goods/Home/pages/main_shell.dart';
import 'package:sudan_goods/user/user_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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

        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>?;
            final role = data?['role'];

            if (role == 'customer') {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              // If already loaded for this uid, go straight to MainShell.
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
                  return const MainShell();
                },
              );
            }

            // Default return statement to handle other cases
            return const Scaffold(
              body: Center(child: Text('Role not recognized')),
            );
          },
        );
      },
    );
  }
}
