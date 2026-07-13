import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sudan_goods/authentication/utils/auth_validators.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({super.key});

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.resetLinkSent)),
      );
      Navigator.of(context).pop(); // close dialog
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = _mapError(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorWithMessage(message),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorWithMessage(
              'An unexpected error occurred. Please try again.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Failed to send reset link. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon header ───────────────────────────────────────
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: OnboardingStyle.brandGradient,
                boxShadow: OnboardingStyle.brandShadow(opacity: 0.20),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            // ── Title ─────────────────────────────────────────────
            Text(
              l10n.resetPassword,
              style: OnboardingStyle.pageTitleStyle(context).copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space8),
            // ── Description ───────────────────────────────────────
            Text(
              l10n.resetPasswordInstructions,
              style: OnboardingStyle.pageSubtitleStyle(context).copyWith(
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space20),
            // ── Email field ───────────────────────────────────────
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _resetPassword(),
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (val) => AuthValidators.email(l10n, val),
              ),
            ),
            const SizedBox(height: DesignTokens.space20),
            // ── Primary CTA ───────────────────────────────────────
            OnboardingPrimaryButton(
              label: l10n.send,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _resetPassword,
            ),
            const SizedBox(height: DesignTokens.space12),
            // ── Cancel ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  overlayColor: AppColors.primary.withValues(alpha: 0.06),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.cancel,
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.text.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
