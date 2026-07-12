import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Shown when the signed-in user has not yet verified their email address.
///
/// Prompts the user to check their inbox, allows resending the verification
/// email, and polls Firebase every 5 seconds so the gate advances
/// automatically once the link is clicked.
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _sending = false;
  bool _resentSuccessfully = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
        _pollTimer?.cancel();
        // authStateChanges will fire and AuthGate will rebuild automatically.
      }
    });
  }

  Future<void> _resend() async {
    setState(() {
      _sending = true;
      _resentSuccessfully = false;
    });
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) setState(() => _resentSuccessfully = true);
    } catch (_) {
      if (mounted) setState(() => _resentSuccessfully = false);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _signOut() async {
    _pollTimer?.cancel();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

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
                        AppColors.primary.withOpacity(0.7),
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
                  'Verify your email',
                  style: AppTypography.heading3.copyWith(color: AppColors.text),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a verification link to',
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
                  'Open the link in your inbox to continue. This page will update automatically.',
                  style: AppTypography.small.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
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
                          'Verification email sent!',
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
                          AppColors.primary.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: _sending ? null : _resend,
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
                                'Resend verification email',
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
                    'Sign out',
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
