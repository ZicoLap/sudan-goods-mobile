/// Registration outcome codes for UI handling
enum RegistrationOutcome {
  success,
  userAlreadyExists,
  validationError,
  networkError,
  serverError,
  unknownError,
}

/// Unified registration result used across the entire client-side flow.
///
/// Produced by [ServerRegisterService] and consumed directly by
/// [RegisterController] and [RegisterPage] — no intermediate re-wrapping.
class RegistrationResult {
  final RegistrationOutcome outcome;
  final String? uid;
  final String? email;
  final String? message;
  final List<String>? validationErrors;

  const RegistrationResult._({
    required this.outcome,
    this.uid,
    this.email,
    this.message,
    this.validationErrors,
  });

  factory RegistrationResult.success({
    required String uid,
    required String email,
    required String message,
  }) => RegistrationResult._(
    outcome: RegistrationOutcome.success,
    uid: uid,
    email: email,
    message: message,
  );

  factory RegistrationResult.error({
    required RegistrationOutcome outcome,
    String? message,
    List<String>? validationErrors,
  }) => RegistrationResult._(
    outcome: outcome,
    message: message,
    validationErrors: validationErrors,
  );

  bool get isSuccess => outcome == RegistrationOutcome.success;
}
