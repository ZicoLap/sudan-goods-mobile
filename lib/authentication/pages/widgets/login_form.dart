import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/controller/login_controller.dart';
import 'package:sudan_goods/authentication/data/login_form_data.dart';
import 'package:sudan_goods/authentication/pages/register_page.dart';
import 'package:sudan_goods/authentication/services/login_service.dart';
import 'package:sudan_goods/authentication/pages/widgets/password_reset_dialog.dart';
import 'package:sudan_goods/core/utils/snackbar_utils.dart';
import 'package:sudan_goods/Home/pages/main_shell.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class LoginForm extends StatefulWidget {
  final LoginFormData formData;

  const LoginForm({super.key, required this.formData});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = LoginController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await _controller.login(
        widget.formData.email.text,
        widget.formData.password.text,
      );

      if (result == "unverified") {
        AppSnackbar.warning(
          context,
          AppLocalizations.of(context)!.verifyEmailPrompt,
        );
        return;
      }
      // Successful login: explicitly navigate to MainShell.
      // AuthGate will also rebuild via authStateChanges, but explicit navigation
      // ensures reliable transition even if stream events are delayed.
      if (result == "success") {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false, // Clear all previous routes
        );
        return;
      }
    } catch (e) {
      // Use user-friendly message from LoginException, fallback for other errors
      final errorMessage =
          e is LoginException
              ? e.message
              : AppLocalizations.of(
                context,
              )!.loginFailedWithError(e.toString());
      AppSnackbar.error(context, errorMessage);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showResetDialog() {
    showDialog(context: context, builder: (_) => const PasswordResetDialog());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Input fields ──────────────────────────────────────────────
        Form(
          key: _formKey,
          child: Column(
            children: [
              _textField(
                widget.formData.email,
                l10n.email,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: DesignTokens.space16),
              _textField(
                widget.formData.password,
                l10n.password,
                obscure: _obscurePassword,
                icon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ],
          ),
        ),
        // ── Forgot password (inline, right-aligned) ───────────────────
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space4,
                vertical: DesignTokens.space8,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _showResetDialog,
            child: Text(
              l10n.forgotPassword,
              style: AppTypography.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.space8),
        // ── Primary CTA — gradient sign-in button ─────────────────────
        _GradientButton(
          label: l10n.login,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _login,
        ),
        const SizedBox(height: DesignTokens.space24),
        // ── OR divider ────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.black.withValues(alpha: 0.10),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space12,
              ),
              child: Text(
                l10n.or,
                style: AppTypography.small.copyWith(
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.black.withValues(alpha: 0.10),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space20),
        // ── Social buttons ────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialCircleButton("assets/images/google_logo.png", () {}),
            const SizedBox(width: DesignTokens.space20),
            _socialCircleButton(null, () {}, icon: Icons.apple),
          ],
        ),
        const SizedBox(height: DesignTokens.space24),
        // ── Register link ─────────────────────────────────────────────
        SizedBox(
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              ),
              foregroundColor: AppColors.primary,
            ),
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
            child: Text(
              l10n.register,
              style: AppTypography.bodyBold.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    IconData? icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffix,
      ),
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? AppLocalizations.of(context)!.pleaseEnterField(label)
                  : null,
    );
  }

  Widget _socialCircleButton(
    String? assetPath,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return Tooltip(
      message: assetPath != null ? 'Google' : 'Apple',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: DesignTokens.shadowSmall,
          ),
          alignment: Alignment.center,
          child:
              assetPath != null
                  ? Image.asset(assetPath, width: 22, height: 22)
                  : Icon(icon, size: 24, color: Colors.black87),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          child: Ink(
            decoration: BoxDecoration(
              gradient:
                  onPressed == null
                      ? LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.4),
                          const Color(0xFFFF8C3A).withValues(alpha: 0.4),
                        ],
                      )
                      : const LinearGradient(
                        colors: [AppColors.primary, Color(0xFFFF8C3A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              boxShadow:
                  onPressed == null
                      ? null
                      : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                      : Text(
                        label,
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
