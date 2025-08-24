import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/controller/register_controller.dart';
import 'package:sudan_goods/authentication/data/register_form_data.dart';
import 'package:sudan_goods/authentication/views/login_page.dart';
import 'package:sudan_goods/authentication/views/widgets/register_form_address.dart';
import 'package:sudan_goods/authentication/views/widgets/register_form_user.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKeyUser = GlobalKey<FormState>();
  final _formKeyAddress = GlobalKey<FormState>();

  final _controller = RegisterController();
  final _formData = RegisterFormData();

  bool _showAddressForm = false;
  bool _isLoading = false;

  String _gender = 'male';
  DateTime _birthday = DateTime(2000, 1, 1);

  @override
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    // Validate address form before submitting
    if (!_formKeyAddress.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final address = Address(
      label: _formData.addressLabel.text.trim(),
      street: _formData.street.text.trim(),
      city: _formData.city.text.trim(),
      country: _formData.country.text.trim(),
      postalCode: _formData.postalCode.text.trim(),
    );

    final result = await _controller.registerUser(
      email: _formData.email.text.trim(),
      password: _formData.password.text.trim(),
      firstName: _formData.firstName.text.trim(),
      lastName: _formData.lastName.text.trim(),
      phoneNumber: _formData.phone.text.trim(),
      gender: _gender,
      birthday: _birthday,
      address: address,
    );

    if (!mounted) return;

    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registrationSuccessVerifyEmail),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else if (result == "unverified") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.verifyEmailPrompt)),
      );
    } else if (result == null) {
      // Please check the console for more details from the controller
      debugPrint("result is null in the register_page.dart");
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.registrationFailedWithError(result),
          ),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.06),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: DesignTokens.paddingPageHorizontal.add(
              const EdgeInsets.symmetric(vertical: DesignTokens.space32),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBubble(_showAddressForm ? Icons.home_rounded : Icons.person_add_alt_1_rounded),
                    const SizedBox(height: DesignTokens.space16),
                    Text(
                      _showAddressForm ? l10n.addressTitle : l10n.register,
                      style: AppTypography.heading4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.space24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                        boxShadow: DesignTokens.shadowSmall,
                      ),
                      padding: const EdgeInsets.all(DesignTokens.space24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: _showAddressForm
                            ? RegisterFormAddress(
                                key: const ValueKey('address_form'),
                                formData: _formData,
                                formKey: _formKeyAddress,
                                isLoading: _isLoading,
                                onSubmit: _submitRegistration,
                                onBack: () => setState(() => _showAddressForm = false),
                              )
                            : RegisterFormUser(
                                key: const ValueKey('user_form'),
                                formData: _formData,
                                formKey: _formKeyUser,
                                gender: _gender,
                                birthday: _birthday,
                                onGenderChanged: (val) => setState(() => _gender = val),
                                onBirthdayChanged: (val) => setState(() => _birthday = val),
                                onNext: () {
                                  if (_formKeyUser.currentState!.validate()) {
                                    if (_formData.password.text != _formData.confirmPassword.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.passwordsDoNotMatch)),
                                      );
                                      return;
                                    }
                                    setState(() => _showAddressForm = true);
                                  }
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _iconBubble(IconData icon) {
  return Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.95),
          AppColors.primary.withOpacity(0.75),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: 36),
  );
}
