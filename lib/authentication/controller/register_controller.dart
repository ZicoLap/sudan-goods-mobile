import 'package:sudan_goods/authentication/services/register_service.dart';
import 'package:sudan_goods/models/user/user_model.dart';
import 'package:sudan_goods/models/shared_models/address.dart';

class RegisterController {
  final RegisterService _service = RegisterService();

  Future<String?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required DateTime birthday,
    required Address address,
  }) async {
    try {
      final user = await _service.createUser(email, password);
      await _service.sendEmailVerification(user);

      final appUser = AppUser(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: "customer",
        gender: gender,
        birthday: birthday,
        createdAt: DateTime.now(),
        phoneNumber: phoneNumber,
        addresses: [address],
      );

      await _service.saveUserToFirestore(appUser);
      await _service.signOut();

      return "success";
    } catch (e) {
      return e.toString();
    }
  }
}
