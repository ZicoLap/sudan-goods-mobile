import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/account/account_service.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Shown when the signed-in user has not yet verified their email address.
///
/// Prompts the user to check their inbox, allows resending the verification
/// email (with a cooldown), and polls Firebase every 5 seconds so the gate
/// advances automatically once the link is clicked. Polling stops after a
/// timeout to preserve battery and avoid indefinite network use.
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  static const _pollIntervalSeconds = 5;
  static const _maxPollAttempts = 60; // 5 minutes
  static const _cooldownSeconds = 60;

  bool _sending = false;
  bool _resentSuccessfully = false;
  bool _timedOut = false;
  int _pollAttempts = 0;
  int _cooldownRemaining = 0;
  Timer? _pollTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _sendInitial();
  }

  Future<void> _sendInitial() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        setState(() => _resentSuccessfully = true);
        _startCooldown();
      }
    } catch (_) {
      // Silently ignore — user can tap Resend manually.
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: _pollIntervalSeconds), (
      _,
    ) async {
      if (!mounted) return;
      _pollAttempts++;
      if (_pollAttempts >= _maxPollAttempts) {
        _pollTimer?.cancel();
        setState(() => _timedOut = true);
        return;
      }

      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
        _pollTimer?.cancel();
        // authStateChanges will fire and AuthGate will rebuild automatically.
      }
    });
  }

  void _startCooldown() {
    _cooldownRemaining = _cooldownSeconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _cooldownRemaining--;
      });
      if (_cooldownRemaining <= 0) {
        _cooldownTimer?.cancel();
      }
    });
  }

  Future<void> _resend() async {
    if (_cooldownRemaining > 0) return;

    setState(() {
      _sending = true;
      _resentSuccessfully = false;
    });
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        setState(() => _resentSuccessfully = true);
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _resentSuccessfully = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorWithMessage(
                'Failed to resend verification email. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _signOut() async {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    await AccountService.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final canResend = !_sending && _cooldownRemaining <= 0;
    final buttonLabel =
        _cooldownRemaining > 0
            ? l10n.resendCooldown(_cooldownRemaining)
            : l10n.resendVerificationEmail;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E8), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.verifyEmailTitle,
                  style: AppTypography.heading3.copyWith(color: AppColors.text),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.verifyEmailSubtitle,
                  style: AppTypography.body.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.verifyEmailInstructions,
                  style: AppTypography.small.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                if (_timedOut) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.verificationTimeoutMessage,
                    style: AppTypography.small.copyWith(
                      color: Colors.orange.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 36),
                if (_resentSuccessfully)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.verificationEmailSent,
                          style: AppTypography.small.copyWith(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: canResend ? _resend : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:
                          _sending
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                buttonLabel,
                                style: AppTypography.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _signOut,
                  child: Text(
                    l10n.logout,
                    style: AppTypography.body.copyWith(color: Colors.black54),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
