import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/authentication/services/account_service.dart';
import 'package:sudan_goods/authentication/utils/auth_validators.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _emailController = TextEditingController();
  bool _verifyBefore = true;
  bool _isSubmitting = false;
  bool _isSyncing = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newEmail = _emailController.text.trim();
    final emailError = AuthValidators.email(l10n, newEmail);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_verifyBefore) {
        await AccountService.instance.changeEmail(newEmail, verifyBefore: true);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.verifyEmailPrompt)));
      } else {
        await AccountService.instance.changeEmail(
          newEmail,
          verifyBefore: false,
          syncFirestore: true,
        );
        if (!mounted) return;
        // Update local provider state if available
        if (userProvider.isUserLoaded) {
          userProvider.updateUser(
            userProvider.currentUser.copyWith(email: newEmail),
          );
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saveChanges)));
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await _promptReauthAndRetry(() async {
          if (_verifyBefore) {
            await AccountService.instance.changeEmail(newEmail, verifyBefore: true);
          } else {
            await AccountService.instance.changeEmail(
              newEmail,
              verifyBefore: false,
              syncFirestore: true,
            );
            if (userProvider.isUserLoaded) {
              userProvider.updateUser(
                userProvider.currentUser.copyWith(email: newEmail),
              );
            }
          }
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.message ?? e.code))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _promptReauthAndRetry(Future<void> Function() retry) async {
    final l10n = AppLocalizations.of(context)!;
    final emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email ?? '',
    );
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.login),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.email),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.password),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.login),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await AccountService.instance.reauthenticateWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );
      await retry();
      if (!mounted) return;
      if (_verifyBefore) {
        // For verify-before-update, keep the page open so user can tap "sync now" after verifying
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.verifyEmailPrompt)));
      } else {
        // For immediate update, we can close the page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saveChanges)));
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.message ?? e.code))),
      );
    }
  }

  Future<void> _syncAfterVerification() async {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() => _isSyncing = true);
    try {
      await AccountService.instance.reloadUser();
      await AccountService.instance.syncEmailToFirestore();

      // Update local provider to reflect the latest auth email
      final authEmail = FirebaseAuth.instance.currentUser?.email;
      if (authEmail != null && userProvider.isUserLoaded) {
        userProvider.updateUser(
          userProvider.currentUser.copyWith(email: authEmail),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saveChanges)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.changeEmail,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          // ── Current email info banner ──────────────────────────────────────
          if (currentEmail.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.email_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current email',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary.withValues(alpha: 0.7),
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          currentEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── New email field ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    hintText: 'name@example.com',
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // ── Verify toggle ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.changeEmailVerifyBeforeLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.changeEmailVerifyBeforeSubtitle,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _verifyBefore,
                        onChanged: (v) => setState(() => _verifyBefore = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Primary action button ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                ),
              ),
              icon:
                  _isSubmitting
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _verifyBefore ? l10n.send : l10n.saveChanges,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // ── Sync button (only shown in verify mode) ────────────────────────
          if (_verifyBefore) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isSyncing ? null : _syncAfterVerification,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusLarge,
                    ),
                  ),
                ),
                icon:
                    _isSyncing
                        ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                        : const Icon(Icons.verified_rounded, size: 18),
                label: Text(
                  l10n.changeEmailSyncNow,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
