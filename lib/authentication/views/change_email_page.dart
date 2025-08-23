import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/authentication/services/account_service.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/user/user_provider.dart';

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
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterField(l10n.email))),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_verifyBefore) {
        await AccountService.changeEmail(newEmail, verifyBefore: true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verifyEmailPrompt)),
        );
      } else {
        await AccountService.changeEmail(newEmail, verifyBefore: false, syncFirestore: true);
        if (!mounted) return;
        // Update local provider state if available
        try {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          if (userProvider.isUserLoaded) {
            userProvider.updateUser(userProvider.currentUser.copyWith(email: newEmail));
          }
        } catch (_) {
          // no-op if provider not available
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.saveChanges)),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await _promptReauthAndRetry(() async {
          if (_verifyBefore) {
            await AccountService.changeEmail(newEmail, verifyBefore: true);
          } else {
            await AccountService.changeEmail(newEmail, verifyBefore: false, syncFirestore: true);
            try {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              if (userProvider.isUserLoaded) {
                userProvider.updateUser(userProvider.currentUser.copyWith(email: newEmail));
              }
            } catch (_) {}
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
      await AccountService.reauthenticateWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );
      await retry();
      if (!mounted) return;
      if (_verifyBefore) {
        // For verify-before-update, keep the page open so user can tap "sync now" after verifying
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verifyEmailPrompt)),
        );
      } else {
        // For immediate update, we can close the page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.saveChanges)),
        );
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
    setState(() => _isSyncing = true);
    try {
      await AccountService.reloadUser();
      await AccountService.syncEmailToFirestore();

      // Update local provider to reflect the latest auth email
      final authEmail = FirebaseAuth.instance.currentUser?.email;
      if (authEmail != null) {
        try {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          if (userProvider.isUserLoaded) {
            userProvider.updateUser(userProvider.currentUser.copyWith(email: authEmail));
          }
        } catch (_) {}
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveChanges)),
      );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.changeEmail),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                hintText: 'name@example.com',
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            SwitchListTile.adaptive(
              value: _verifyBefore,
              onChanged: (v) => setState(() => _verifyBefore = v),
              title: Text(l10n.changeEmailVerifyBeforeLabel),
              subtitle: Text(l10n.changeEmailVerifyBeforeSubtitle),
            ),
            const SizedBox(height: DesignTokens.space16),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.email_outlined),
                label: Text(_verifyBefore ? l10n.send : l10n.saveChanges),
              ),
            ),
            if (_verifyBefore) ...[
              const SizedBox(height: DesignTokens.space12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isSyncing ? null : _syncAfterVerification,
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: Text(l10n.changeEmailSyncNow),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
