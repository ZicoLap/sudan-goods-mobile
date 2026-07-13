/// Typed result for an authentication attempt.
///
/// Replaces stringly-typed `"success"` / `"unverified"` / `"error"` values
/// with a sealed class hierarchy that is type-safe and extensible.
sealed class LoginResult {
  const LoginResult();
}

/// Authentication succeeded and the user's email is verified.
final class LoginSuccess extends LoginResult {
  const LoginSuccess();
}

/// Authentication succeeded but the user's email is not yet verified.
final class LoginUnverified extends LoginResult {
  const LoginUnverified();
}

/// Authentication failed with a user-friendly message and optional code.
final class LoginFailure extends LoginResult {
  final String message;
  final String code;

  const LoginFailure(this.message, {this.code = 'unknown'});
}
