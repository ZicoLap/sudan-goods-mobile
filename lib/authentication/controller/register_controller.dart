import 'package:sudan_goods/authentication/data/registration_result.dart';
import 'package:sudan_goods/authentication/services/server_register_service.dart';
import 'package:sudan_goods/models/shared_models/address.dart';

export 'package:sudan_goods/authentication/data/registration_result.dart';

/// Controller for user registration via secure Cloud Function.
///
/// Delegates entirely to [ServerRegisterService]. The controller is the
/// appropriate place to add cross-cutting concerns (analytics, retry logic,
/// ChangeNotifier state) without coupling the service or UI to each other.
class RegisterController {
  final ServerRegisterService _service;

  RegisterController({ServerRegisterService? service})
    : _service = service ?? ServerRegisterService();

  /// Register a new user.
  ///
  /// Returns a [RegistrationResult] with structured outcome for UI handling.
  Future<RegistrationResult> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required DateTime birthday,
    required Address address,
  }) {
    return _service.registerUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      gender: gender,
      birthday: birthday,
      address: address,
    );
  }
}
