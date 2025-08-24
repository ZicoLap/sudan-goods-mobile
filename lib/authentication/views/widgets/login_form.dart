import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/controller/login_controller.dart';
import 'package:sudan_goods/authentication/data/login_form_data.dart';
import 'package:sudan_goods/authentication/views/register_page.dart';
import 'package:sudan_goods/authentication/views/widgets/password_reset_dialog.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.verifyEmailPrompt)),
        );
        return;
      }
      // Successful login: let AuthGate (listening to authStateChanges) rebuild
      // to MainShell and fetch the user. No manual navigation here.
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.loginFailedWithError(e.toString()),
          ),
        ),
      );
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
        Form(
          key: _formKey,
          child: Column(
            children: [
              _textField(
                widget.formData.email,
                l10n.email,
                icon: Icons.email,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: DesignTokens.space24),
              _textField(
                widget.formData.password,
                l10n.password,
                obscure: _obscurePassword,
                icon: Icons.lock,
                textInputAction: TextInputAction.done,
                suffix: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialCircleButton("assets/images/google_logo.png", () {}),
            const SizedBox(width: DesignTokens.space24),
            _socialCircleButton(null, () {}, icon: Icons.apple),
          ],
        ),
        const SizedBox(height: DesignTokens.space24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(l10n.login, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.black.withOpacity(0.12), thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                l10n.or,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Divider(color: Colors.black.withOpacity(0.12), thickness: 1)),
          ],
        ),
        const SizedBox(height: DesignTokens.space24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(l10n.register, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: DesignTokens.space12),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: _showResetDialog,
            child: Text(l10n.forgotPassword),
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
    TextInputAction? textInputAction,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffix,
      ),
      validator: (val) => val == null || val.isEmpty
          ? AppLocalizations.of(context)!.pleaseEnterField(label)
          : null,
    );
  }

  Widget _socialCircleButton(
    String? assetPath,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: DesignTokens.shadowSmall,
        ),
        alignment: Alignment.center,
        child: assetPath != null
            ? Image.asset(assetPath, width: 20, height: 20)
            : Icon(icon, size: 24, color: Colors.black),
      ),
    );
  }
}
