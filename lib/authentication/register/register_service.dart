import 'package:cloud_functions/cloud_functions.dart';
import 'package:sudan_goods/authentication/register/registration_result.dart';
import 'package:sudan_goods/models/shared_models/address.dart';

/// Server-side registration service.
///
/// This service ONLY communicates with Cloud Functions and does NOT
/// perform any direct Firebase Auth or Firestore operations.
class ServerRegisterService {
  final FirebaseFunctions _functions;

  ServerRegisterService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  /// Register a new user via secure Cloud Function.
  ///
  /// The Cloud Function handles:
  /// - Input validation
  /// - Firebase Auth user creation
  /// - Firestore document creation
  /// - Atomic rollback on failure
  Future<RegistrationResult> registerUser({
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
      final callable = _functions.httpsCallable('registerUser');

      final response = await callable.call({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'birthday': birthday.toIso8601String(),
        'address': {
          'street': address.street,
          'city': address.city,
          'country': address.country,
          'postalCode': address.postalCode,
          'label': address.label,
        },
      });

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return RegistrationResult.success(
          uid: data['uid'] as String,
          email: data['email'] as String,
          message: data['message'] as String,
        );
      }

      return RegistrationResult.error(
        outcome: _outcomeFromDomainCode(data['code'] as String?),
        message: data['message'] as String? ?? 'Registration failed',
        validationErrors: (data['details'] as List<dynamic>?)?.cast<String>(),
      );
    } on FirebaseFunctionsException catch (e) {
      return _handleFunctionsException(e);
    } catch (e) {
      return RegistrationResult.error(
        outcome: RegistrationOutcome.unknownError,
        message: 'An unexpected error occurred. Please try again later.',
      );
    }
  }

  /// Converts a [FirebaseFunctionsException] to a [RegistrationResult].
  ///
  /// Prefers the domain-level code embedded in [e.details] (set by the Cloud
  /// Function) and falls back to the generic Firebase HTTP error code.
  RegistrationResult _handleFunctionsException(FirebaseFunctionsException e) {
    final rawDetails = e.details as Map<dynamic, dynamic>?;
    final domainCode = rawDetails?['code'] as String?;
    final message =
        rawDetails?['message'] as String? ?? e.message ?? 'Registration failed';
    final validationErrors =
        (rawDetails?['details'] as List<dynamic>?)?.cast<String>();

    final outcome =
        domainCode != null
            ? _outcomeFromDomainCode(domainCode)
            : _outcomeFromHttpCode(e.code);

    return RegistrationResult.error(
      outcome: outcome,
      message: message,
      validationErrors: validationErrors,
    );
  }

  /// Maps the backend domain error code (e.g. "USER_EXISTS") to an outcome.
  RegistrationOutcome _outcomeFromDomainCode(String? code) {
    switch (code) {
      case 'VALIDATION_ERROR':
        return RegistrationOutcome.validationError;
      case 'USER_EXISTS':
        return RegistrationOutcome.userAlreadyExists;
      case 'AUTH_ERROR':
        return RegistrationOutcome.serverError;
      case 'DATABASE_ERROR':
        return RegistrationOutcome.serverError;
      case 'INTERNAL_ERROR':
        return RegistrationOutcome.serverError;
      default:
        return RegistrationOutcome.unknownError;
    }
  }

  /// Fallback: maps a Firebase HTTP error code to an outcome when no domain
  /// code is present in the exception details.
  RegistrationOutcome _outcomeFromHttpCode(String code) {
    switch (code) {
      case 'invalid-argument':
        return RegistrationOutcome.validationError;
      case 'already-exists':
        return RegistrationOutcome.userAlreadyExists;
      case 'unavailable':
        return RegistrationOutcome.serverError;
      case 'deadline-exceeded':
      case 'resource-exhausted':
        return RegistrationOutcome.networkError;
      case 'unauthenticated':
      case 'permission-denied':
        return RegistrationOutcome.serverError;
      default:
        return RegistrationOutcome.unknownError;
    }
  }
}
