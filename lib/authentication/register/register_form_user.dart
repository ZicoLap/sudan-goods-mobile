import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudan_goods/authentication/register/register_form_data.dart';
import 'package:sudan_goods/authentication/login/login_page.dart';
import 'package:sudan_goods/authentication/utils/auth_validators.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/authentication/widgets/gender_picker.dart';
import 'package:sudan_goods/authentication/widgets/birthday_picker.dart';

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Name row ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      context,
                      widget.formData.firstName,
                      l10n.firstName,
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      capitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: _textField(
                      context,
                      widget.formData.lastName,
                      l10n.lastName,
                      textInputAction: TextInputAction.next,
                      capitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space16),
              _textField(
                context,
                widget.formData.email,
                l10n.email,
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (val) => AuthValidators.email(l10n, val),
              ),
              const SizedBox(height: DesignTokens.space16),
              _textField(
                context,
                widget.formData.phone,
                l10n.phone,
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                ],
              ),
              const SizedBox(height: DesignTokens.space20),
              // ── Password section label ─────────────────────────
              Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  bottom: DesignTokens.space12,
                ),
                child: Text(
                  l10n.password,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.40),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              _textField(
                context,
                widget.formData.password,
                l10n.password,
                obscure: _obscurePassword,
                icon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (val) => AuthValidators.password(l10n, val),
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
              const SizedBox(height: DesignTokens.space16),
              _textField(
                context,
                widget.formData.confirmPassword,
                l10n.confirmPassword,
                obscure: _obscureConfirm,
                icon: Icons.lock_rounded,
                textInputAction: TextInputAction.done,
                validator:
                    (val) => AuthValidators.confirmPassword(
                      l10n,
                      val,
                      widget.formData.password.text,
                    ),
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed:
                      () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: DesignTokens.space20),
              // ── Gender & Birthday ──────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 360;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GenderPicker(
                          gender: widget.gender,
                          onChanged: widget.onGenderChanged,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
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
        // ── Gradient CTA ──────────────────────────────────────────
        OnboardingPrimaryButton(
          label: l10n.next,
          showTrailingIcon: true,
          onPressed: widget.onNext,
        ),
        const SizedBox(height: DesignTokens.space16),
        // ── Already have an account? ───────────────────────────────
        Center(
          child: TextButton(
            style: TextButton.styleFrom(
              overlayColor: AppColors.primary.withValues(alpha: 0.06),
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            child: RichText(
              text: TextSpan(
                style: AppTypography.body.copyWith(
                  color: AppColors.text.withValues(alpha: 0.50),
                ),
                children: [
                  const TextSpan(text: 'Already have an account?  '),
                  TextSpan(
                    text: l10n.login,
                    style: OnboardingStyle.pageEyebrowStyle(context).copyWith(
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
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
    TextInputType? keyboard,
    TextInputAction? textInputAction,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textInputAction: textInputAction,
      textCapitalization: capitalization,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        suffixIcon: suffix,
      ),
      validator:
          validator ??
          (val) =>
              val == null || val.isEmpty
                  ? AppLocalizations.of(context)!.pleaseEnterField(label)
                  : null,
    );
  }
}
