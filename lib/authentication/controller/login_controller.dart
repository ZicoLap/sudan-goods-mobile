
import 'package:sudan_goods/authentication/services/login_service.dart';

class LoginController {
  final LoginService _service = LoginService();

  Future<String?> login(String email, String password) async {
    try {
      final user = await _service.loginWithEmail(email, password);

      if (user != null) {
        final refreshedUser = await _service.refreshUser();

        if (refreshedUser != null && !refreshedUser.emailVerified) {
          await _service.sendVerificationEmail(refreshedUser);
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
