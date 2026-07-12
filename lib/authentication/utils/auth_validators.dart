import 'package:sudan_goods/l10n/app_localizations.dart';

/// Reusable, localized input validators for the authentication flows.
class AuthValidators {
  static final _emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');

  /// Validates that a required field is not empty after trimming.
  static String? required(
    AppLocalizations l10n,
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterField(fieldName);
    }
    return null;
  }

  /// Validates an email address format.
  static String? email(AppLocalizations l10n, String? value) {
    final base = required(l10n, value, l10n.email);
    if (base != null) return base;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return l10n.invalidEmail;
    }
    return null;
  }

  /// Validates a password meets minimum requirements.
  ///
  /// Currently requires at least 8 characters. Extend here for complexity
  /// rules (uppercase, lowercase, number, special character) when needed.
  static String? password(AppLocalizations l10n, String? value) {
    final base = required(l10n, value, l10n.password);
    if (base != null) return base;
    if (value!.length < 8) {
      return l10n.passwordTooShort;
    }
    return null;
  }

  /// Validates that [confirmValue] matches [passwordValue].
  static String? confirmPassword(
    AppLocalizations l10n,
    String? confirmValue,
    String passwordValue,
  ) {
    final base = required(l10n, confirmValue, l10n.confirmPassword);
    if (base != null) return base;
    if (confirmValue != passwordValue) {
      return l10n.passwordsDoNotMatch;
    }
    return null;
  }
}
