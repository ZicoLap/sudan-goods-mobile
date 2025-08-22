import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudan_goods/authentication/data/register_form_data.dart';
import 'package:sudan_goods/authentication/views/login_page.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'gender_picker.dart';
import 'birthday_picker.dart';

class RegisterFormUser extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      key: const ValueKey('user_form'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.register,
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
                _textField(context, formData.firstName, l10n.firstName),
                const SizedBox(height: 16),
                _textField(context, formData.lastName, l10n.lastName),
                const SizedBox(height: 16),
                _textField(context, formData.email, l10n.email, icon: Icons.email),
                const SizedBox(height: 16),
                _textField(context, formData.phone, l10n.phone, icon: Icons.phone),
                const SizedBox(height: 16),
                _textField(
                  context,
                  formData.password,
                  l10n.password,
                  obscure: true,
                  icon: Icons.lock_outline,
                ),
                const SizedBox(height: 16),
                _textField(
                  context,
                  formData.confirmPassword,
                  l10n.confirmPassword,
                  obscure: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GenderPicker(gender: gender, onChanged: onGenderChanged),
                    const SizedBox(width: 16),
                    BirthdayPicker(
                      birthday: birthday,
                      onPicked: onBirthdayChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
              child: Text(
                l10n.next,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              child: Text(
                l10n.cancel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    bool obscure = false,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
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
