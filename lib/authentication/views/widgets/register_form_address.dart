import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudan_goods/authentication/data/register_form_data.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

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
    return SingleChildScrollView(
      key: const ValueKey('address_form'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.addressTitle,
            style: GoogleFonts.staatliches(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: formKey,
            child: Column(
              children: [
                _textField(context, formData.addressLabel, l10n.addressLabelPlaceholder),
                const SizedBox(height: 16),
                _textField(context, formData.street, l10n.street),
                const SizedBox(height: 16),
                _textField(context, formData.city, l10n.city),
                const SizedBox(height: 16),
                _textField(context, formData.country, l10n.country),
                const SizedBox(height: 16),
                _textField(context, formData.postalCode, l10n.postalCode),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.register),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: isLoading ? null : onBack,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.back),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField(BuildContext context, TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
        ),
      ),
      validator: (val) => val == null || val.isEmpty
          ? AppLocalizations.of(context)!.pleaseEnterField(label)
          : null,
    );
  }
}
