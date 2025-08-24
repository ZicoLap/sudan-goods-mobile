import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/data/register_form_data.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
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
            children: [
              _textField(context, formData.addressLabel, l10n.addressLabelPlaceholder),
              const SizedBox(height: DesignTokens.space16),
              _textField(context, formData.street, l10n.street),
              const SizedBox(height: DesignTokens.space16),
              _textField(context, formData.city, l10n.city),
              const SizedBox(height: DesignTokens.space16),
              _textField(context, formData.country, l10n.country),
              const SizedBox(height: DesignTokens.space16),
              _textField(context, formData.postalCode, l10n.postalCode),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.register),
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: isLoading ? null : onBack,
            child: Text(l10n.back),
          ),
        ),
      ],
    );
  }

  Widget _textField(BuildContext context, TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (val) => val == null || val.isEmpty
          ? AppLocalizations.of(context)!.pleaseEnterField(label)
          : null,
    );
  }
}
