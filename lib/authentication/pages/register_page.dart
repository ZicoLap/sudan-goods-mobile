import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/controller/register_controller.dart';
import 'package:sudan_goods/authentication/data/register_form_data.dart';
import 'package:sudan_goods/authentication/pages/login_page.dart';
import 'package:sudan_goods/authentication/pages/widgets/register_form_address.dart';
import 'package:sudan_goods/authentication/pages/widgets/register_form_user.dart';
import 'package:sudan_goods/core/utils/snackbar_utils.dart';
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

    // Handle structured registration result
    if (result.isSuccess) {
      // Success: show success message and navigate to login
      AppSnackbar.success(
        context,
        result.message ?? 'Registration successful! Please verify your email.',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      // Handle different error types with appropriate messages
      _handleRegistrationError(result);
    }

    setState(() => _isLoading = false);
  }

  /// Handle registration errors with user-friendly messages
  void _handleRegistrationError(RegistrationResult result) {
    switch (result.outcome) {
      case RegistrationOutcome.validationError:
        // Show validation errors (multiple field errors)
        final errors = result.validationErrors;
        if (errors != null && errors.isNotEmpty) {
          // Show first error with indication of more
          final message =
              errors.length > 1
                  ? '${errors.first}\n(${errors.length - 1} more issues)'
                  : errors.first;
          AppSnackbar.error(context, message);
        } else {
          AppSnackbar.error(
            context,
            'Please check your information and try again.',
          );
        }
      case RegistrationOutcome.userAlreadyExists:
        AppSnackbar.error(
          context,
          'This email is already registered. Please sign in or use a different email.',
          actionLabel: 'Sign In',
          onAction:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
        );
      case RegistrationOutcome.networkError:
        AppSnackbar.error(
          context,
          'Please check your internet connection and try again.',
        );
      case RegistrationOutcome.serverError:
        AppSnackbar.error(
          context,
          'Server error. Please try again in a few moments.',
        );
      case RegistrationOutcome.unknownError:
        AppSnackbar.error(
          context,
          result.message ?? 'Something went wrong. Please try again.',
        );
      case RegistrationOutcome.success:
        // Should never reach here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient (matches login page) ─────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    AppColors.primary.withValues(alpha: 0.03),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.35, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: DesignTokens.paddingPageHorizontal.add(
                const EdgeInsets.only(
                  top: DesignTokens.space48,
                  bottom: DesignTokens.space32,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Icon bubble ─────────────────────────────
                      _iconBubble(
                        _showAddressForm
                            ? Icons.home_rounded
                            : Icons.person_add_alt_1_rounded,
                      ),
                      const SizedBox(height: DesignTokens.space20),
                      // ── App title ───────────────────────────────
                      Text(
                        l10n.appTitle,
                        style: AppTypography.heading5.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      // ── Page title ──────────────────────────────
                      Text(
                        _showAddressForm ? l10n.addressTitle : l10n.register,
                        style: AppTypography.heading4.copyWith(
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      // ── Subtitle ────────────────────────────────
                      Text(
                        _showAddressForm
                            ? 'Almost there — just your delivery address'
                            : 'Create your account to start shopping',
                        style: AppTypography.body.copyWith(
                          color: Colors.black45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      // ── Step indicator ──────────────────────────
                      _StepIndicator(step: _showAddressForm ? 2 : 1, total: 2),
                      const SizedBox(height: DesignTokens.space24),
                      // ── Form card ───────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXLarge,
                          ),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(DesignTokens.space24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (child, animation) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                          child:
                              _showAddressForm
                                  ? RegisterFormAddress(
                                    key: const ValueKey('address_form'),
                                    formData: _formData,
                                    formKey: _formKeyAddress,
                                    isLoading: _isLoading,
                                    onSubmit: _submitRegistration,
                                    onBack:
                                        () => setState(
                                          () => _showAddressForm = false,
                                        ),
                                  )
                                  : RegisterFormUser(
                                    key: const ValueKey('user_form'),
                                    formData: _formData,
                                    formKey: _formKeyUser,
                                    gender: _gender,
                                    birthday: _birthday,
                                    onGenderChanged:
                                        (val) => setState(() => _gender = val),
                                    onBirthdayChanged:
                                        (val) =>
                                            setState(() => _birthday = val),
                                    onNext: () {
                                      if (_formKeyUser.currentState!
                                          .validate()) {
                                        if (_formData.password.text !=
                                            _formData.confirmPassword.text) {
                                          AppSnackbar.warning(
                                            context,
                                            l10n.passwordsDoNotMatch,
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
        ],
      ),
    );
  }
}

Widget _iconBubble(IconData icon) {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [AppColors.primary, Color(0xFFFF8C3A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: 38),
  );
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final int total;
  const _StepIndicator({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i + 1 == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                active
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          ),
        );
      }),
    );
  }
}
