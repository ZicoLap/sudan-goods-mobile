import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/data/register_form_data.dart';
import 'package:sudan_goods/authentication/views/login_page.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'gender_picker.dart';
import 'birthday_picker.dart';

class RegisterFormUser extends StatefulWidget {
  final RegisterFormData formData;
  final GlobalKey<FormState> formKey;
  final String gender;
  final DateTime birthday;
  final Function(String) onGenderChanged;
  final Function(DateTime) onBirthdayChanged;
  final VoidCallback onNext;

  const RegisterFormUser({
    super.key,
    required this.formData,
    required this.formKey,
    required this.gender,
    required this.birthday,
    required this.onGenderChanged,
    required this.onBirthdayChanged,
    required this.onNext,
  });

  @override
  State<RegisterFormUser> createState() => _RegisterFormUserState();
}

class _RegisterFormUserState extends State<RegisterFormUser> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('user_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: widget.formKey,
          child: Column(
            children: [
              _textField(context, widget.formData.firstName, l10n.firstName),
              const SizedBox(height: DesignTokens.space16),
              _textField(context, widget.formData.lastName, l10n.lastName),
              const SizedBox(height: DesignTokens.space16),
              _textField(context, widget.formData.email, l10n.email, icon: Icons.email),
              const SizedBox(height: DesignTokens.space16),
              _textField(context, widget.formData.phone, l10n.phone, icon: Icons.phone),
              const SizedBox(height: DesignTokens.space16),
              _textField(
                context,
                widget.formData.password,
                l10n.password,
                obscure: _obscurePassword,
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              _textField(
                context,
                widget.formData.confirmPassword,
                l10n.confirmPassword,
                obscure: _obscureConfirm,
                icon: Icons.lock,
                suffix: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 400;
                  if (isNarrow) {
                    return Column(
                      children: [
                        GenderPicker(
                          gender: widget.gender,
                          onChanged: widget.onGenderChanged,
                        ),
                        const SizedBox(height: DesignTokens.space16),
                        BirthdayPicker(
                          birthday: widget.birthday,
                          onPicked: widget.onBirthdayChanged,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: GenderPicker(
                          gender: widget.gender,
                          onChanged: widget.onGenderChanged,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      Expanded(
                        child: BirthdayPicker(
                          birthday: widget.birthday,
                          onPicked: widget.onBirthdayChanged,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: widget.onNext,
            child: Text(l10n.next, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _textField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    bool obscure = false,
    IconData? icon,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
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
}
