import 'package:sudan_goods/authentication/data/login_result.dart';
import 'package:sudan_goods/authentication/services/login_service.dart';

class LoginController {
  final LoginService _service;

  LoginController({LoginService? service}) : _service = service ?? LoginService();

  /// Attempts to log in with email and password.
  ///
  /// Returns a [LoginResult] indicating success, unverified email, or failure.
  Future<LoginResult> login(String email, String password) async {
    try {
      final user = await _service.loginWithEmail(email, password);

      if (user == null) {
        return const LoginFailure('Unexpected login error. Please try again.');
      }

      final refreshedUser = await _service.refreshUser();

      if (refreshedUser != null && !refreshedUser.emailVerified) {
        // Return unverified status - do NOT send verification email here.
        // Verification emails are requested on EmailVerificationPage.
        return const LoginUnverified();
      }
      return const LoginSuccess();
    } on LoginException catch (e) {
      return LoginFailure(e.message, code: e.code);
    } catch (e) {
      return LoginFailure('Login failed. Please try again.');
    }
  }
}
