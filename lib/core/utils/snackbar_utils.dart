import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';

/// Snackbar types for different feedback states
enum SnackbarType {
  success,
  error,
  warning,
  info,
}

/// A utility class for showing consistent, modern snackbars across the app.
/// 
/// Usage:
/// ```dart
/// AppSnackbar.success(context, 'Registration successful!');
/// AppSnackbar.error(context, 'Something went wrong');
/// AppSnackbar.show(context, 'Custom message', type: SnackbarType.warning);
/// ```
class AppSnackbar {
  AppSnackbar._(); // Private constructor to prevent instantiation

  // Duration constants
  static const Duration _shortDuration = Duration(seconds: 2);
  static const Duration _longDuration = Duration(seconds: 4);

  /// Shows a success snackbar (green)
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message,
      type: SnackbarType.success,
      duration: duration ?? _shortDuration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Shows an error snackbar (red)
  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message,
      type: SnackbarType.error,
      duration: duration ?? _longDuration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Shows a warning snackbar (orange)
  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message,
      type: SnackbarType.warning,
      duration: duration ?? _longDuration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Shows an info snackbar (blue/primary)
  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message,
      type: SnackbarType.info,
      duration: duration ?? _shortDuration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Generic show method with full customization
  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    final colorScheme = _getColorScheme(type, theme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              colorScheme.icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.background,
        duration: duration ?? _shortDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Hide any currently showing snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Get color scheme based on snackbar type
  static _ColorScheme _getColorScheme(SnackbarType type, ThemeData theme) {
    switch (type) {
      case SnackbarType.success:
        return _ColorScheme(
          background: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );
      case SnackbarType.error:
        return _ColorScheme(
          background: Colors.red.shade700,
          icon: Icons.error_outline,
        );
      case SnackbarType.warning:
        return _ColorScheme(
          background: Colors.orange.shade700,
          icon: Icons.warning_amber_outlined,
        );
      case SnackbarType.info:
        return _ColorScheme(
          background: AppColors.primary,
          icon: Icons.info_outline,
        );
    }
  }
}

/// Internal color scheme holder
class _ColorScheme {
  final Color background;
  final IconData icon;

  const _ColorScheme({
    required this.background,
    required this.icon,
  });
}
