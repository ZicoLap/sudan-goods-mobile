import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/register/register_form_data.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class RegisterFormAddress extends StatelessWidget {
  final RegisterFormData formData;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const RegisterFormAddress({
    super.key,
    required this.formData,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('address_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _textField(
                context,
                formData.addressLabel,
                l10n.addressLabelPlaceholder,
                icon: Icons.label_outline_rounded,
                textInputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: DesignTokens.space16),
              _textField(
                context,
                formData.street,
                l10n.street,
                icon: Icons.signpost_outlined,
                textInputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: DesignTokens.space16),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      context,
                      formData.city,
                      l10n.city,
                      icon: Icons.location_city_outlined,
                      textInputAction: TextInputAction.next,
                      capitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: _textField(
                      context,
                      formData.postalCode,
                      l10n.postalCode,
                      icon: Icons.markunread_mailbox_outlined,
                      keyboard: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space16),
              _textField(
                context,
                formData.country,
                l10n.country,
                icon: Icons.public_outlined,
                textInputAction: TextInputAction.done,
                capitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        // ── Gradient submit ───────────────────────────────────────
        OnboardingPrimaryButton(
          label: l10n.register,
          isLoading: isLoading,
          onPressed: isLoading ? null : onSubmit,
        ),
        const SizedBox(height: DesignTokens.space12),
        // ── Back link ─────────────────────────────────────────────
        Center(
          child: TextButton.icon(
            onPressed: isLoading ? null : onBack,
            style: TextButton.styleFrom(
              overlayColor: AppColors.primary.withValues(alpha: 0.06),
            ),
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            label: Text(
              l10n.back,
              style: OnboardingStyle.pageEyebrowStyle(context).copyWith(
                fontSize: 13,
                letterSpacing: 0.3,
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
    IconData? icon,
    TextInputType? keyboard,
    TextInputAction? textInputAction,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      textInputAction: textInputAction,
      textCapitalization: capitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      ),
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? AppLocalizations.of(context)!.pleaseEnterField(label)
                  : null,
    );
  }
}
