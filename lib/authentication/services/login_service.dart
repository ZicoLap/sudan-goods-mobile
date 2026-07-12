// features/auth/services/login_service.dart
import 'package:firebase_auth/firebase_auth.dart';

/// Custom exception for login failures with user-friendly messages.
class LoginException implements Exception {
  final String message;
  final String code;

  LoginException(this.message, {this.code = 'unknown'});

  @override
  String toString() => message;
}

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-email':
          throw LoginException(
            'Invalid email or password. Please try again.',
            code: e.code,
          );
        case 'too-many-requests':
          throw LoginException(
            'Too many failed attempts. Please try again later.',
            code: e.code,
          );
        case 'network-request-failed':
          throw LoginException(
            'Network error. Please check your connection and try again.',
            code: e.code,
          );
        case 'user-disabled':
          throw LoginException(
            'This account has been disabled. Please contact support.',
            code: e.code,
          );
        default:
          throw LoginException('Login failed. Please try again.', code: e.code);
      }
    }
  }

  Future<void> sendVerificationEmail(User user) async {
    await user.sendEmailVerification();
  }

  Future<User?> refreshUser() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser;
  }
}
