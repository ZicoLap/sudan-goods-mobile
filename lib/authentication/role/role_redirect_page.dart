import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Shown when a user with a non-customer role signs in.
/// Provides clear messaging and actions based on their actual role.
class RoleRedirectPage extends StatelessWidget {
  final String role;
  final String? customMessage;

  const RoleRedirectPage({super.key, required this.role, this.customMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: DesignTokens.paddingPageHorizontal.add(
              const EdgeInsets.symmetric(vertical: 48),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(height: DesignTokens.space32),
                  Text(
                    _buildTitle(),
                    style: AppTypography.heading4.copyWith(
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  Text(
                    customMessage ?? _buildMessage(),
                    style: AppTypography.body.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space32),
                  _buildActionButton(context),
                  const SizedBox(height: DesignTokens.space16),
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final IconData icon;
    final Color color;

    switch (role) {
      case 'vendor':
        icon = Icons.store_outlined;
        color = Colors.orange;
        break;
      case 'admin':
        icon = Icons.admin_panel_settings_outlined;
        color = Colors.purple;
        break;
      case 'delivery':
        icon = Icons.delivery_dining_outlined;
        color = Colors.green;
        break;
      default:
        icon = Icons.block_outlined;
        color = Colors.red;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
      ),
      child: Icon(icon, size: 48, color: color),
    );
  }

  String _buildTitle() {
    switch (role) {
      case 'vendor':
        return 'Vendor Account Detected';
      case 'admin':
        return 'Admin Account Detected';
      case 'delivery':
        return 'Delivery Account Detected';
      default:
        return 'Access Restricted';
    }
  }

  String _buildMessage() {
    switch (role) {
      case 'vendor':
        return 'This is the customer app. Please use the Vendor Portal app to manage your store and products.';
      case 'admin':
        return 'This is the customer app. Please use the Admin Dashboard to manage the platform.';
      case 'delivery':
        return 'This is the customer app. Please use the Delivery Driver app to accept and manage orders.';
      default:
        return 'Your account does not have access to this application. Please contact support if you believe this is an error.';
    }
  }

  Widget _buildActionButton(BuildContext context) {
    final String label;
    final VoidCallback? onPressed;

    switch (role) {
      case 'vendor':
        label = 'Go to Vendor Portal';
        // TODO: Deep link to vendor app or open web portal
        onPressed = () {
          // Launch vendor portal URL or deep link
          _showComingSoon(context);
        };
        break;
      case 'admin':
        label = 'Go to Admin Dashboard';
        onPressed = () {
          // Launch admin dashboard URL
          _showComingSoon(context);
        };
        break;
      default:
        label = 'Contact Support';
        onPressed = () {
          // Open support contact
          _showComingSoon(context);
        };
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          ),
        ),
        child: Text(label, style: AppTypography.bodyBold),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Coming Soon'),
            content: const Text(
              'This feature is not yet available. Please sign out and use the appropriate application for your account type.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

/// Shown when the user's role is unknown or null.
/// This could indicate incomplete registration or data corruption.
class UnknownRolePage extends StatelessWidget {
  const UnknownRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: DesignTokens.paddingPageHorizontal.add(
              const EdgeInsets.symmetric(vertical: 48),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.warning_amber_outlined,
                      size: 48,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space32),
                  Text(
                    'Account Setup Incomplete',
                    style: AppTypography.heading4.copyWith(
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  Text(
                    'We\'re having trouble loading your account information. This may be due to a network issue or incomplete registration.',
                    style: AppTypography.body.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Trigger rebuild by navigating to self
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const _RetryGate()),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusRound,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal widget to trigger AuthGate rebuild
class _RetryGate extends StatelessWidget {
  const _RetryGate();

  @override
  Widget build(BuildContext context) {
    // This will rebuild AuthGate from scratch
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
