import 'package:sudan_goods/authentication/services/login_service.dart';

class LoginController {
  final LoginService _service = LoginService();

  /// Attempts to log in with email and password.
  ///
  /// Returns:
  /// - "success" if login succeeded and email is verified
  /// - "unverified" if login succeeded but email is not verified
  /// - throws on login failure (see LoginException for user-friendly errors)
  Future<String?> login(String email, String password) async {
    try {
      final user = await _service.loginWithEmail(email, password);

      if (user != null) {
        final refreshedUser = await _service.refreshUser();

        if (refreshedUser != null && !refreshedUser.emailVerified) {
          // Return unverified status - do NOT send verification email here.
          // Verification emails should only be sent at registration time.
          return "unverified";
        }
        return "success";
      }

      return "error"; // unexpected case
    } catch (e) {
      rethrow; // bubble up to UI for error message
    }
  }
}
