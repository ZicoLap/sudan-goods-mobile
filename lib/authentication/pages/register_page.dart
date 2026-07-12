import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/controller/register_controller.dart';
import 'package:sudan_goods/authentication/data/register_form_data.dart';
import 'package:sudan_goods/authentication/pages/login_page.dart';
import 'package:sudan_goods/authentication/pages/widgets/auth_card.dart';
import 'package:sudan_goods/authentication/pages/widgets/auth_eyebrow.dart';
import 'package:sudan_goods/authentication/pages/widgets/register_form_address.dart';
import 'package:sudan_goods/authentication/pages/widgets/register_form_user.dart';
import 'package:sudan_goods/core/utils/snackbar_utils.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/authentication/pages/widgets/auth_illustrations.dart';
import 'package:sudan_goods/onboarding/onboarding_animations.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKeyUser = GlobalKey<FormState>();
  final _formKeyAddress = GlobalKey<FormState>();

  final _controller = RegisterController();
  final _formData = RegisterFormData();

  bool _showAddressForm = false;
  bool _isLoading = false;

  String _gender = 'male';
  DateTime _birthday = DateTime(2000, 1, 1);

  late final AnimationController _stagger;
  static const _kDuration = Duration(milliseconds: 900);
  late final Animation<double> _animIllustration;
  late final Animation<double> _animEyebrow;
  late final Animation<double> _animHeading;
  late final Animation<double> _animForm;

  Animation<double> _interval(double begin, double end) =>
      CurvedAnimation(
        parent: _stagger,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(vsync: this, duration: _kDuration)
      ..forward();
    _animIllustration = _interval(0.00, 0.55);
    _animEyebrow      = _interval(0.18, 0.65);
    _animHeading      = _interval(0.32, 0.78);
    _animForm         = _interval(0.48, 1.00);
  }

  @override
  void dispose() {
    _stagger.dispose();
    _formData.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    final l10n = AppLocalizations.of(context)!;

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
      // Verification email is intentionally not sent here. The user must
      // sign in first; AuthGate will route unverified users to the
      // EmailVerificationPage where they can request the verification link.
      if (!mounted) return;
      AppSnackbar.success(
        context,
        result.message ?? l10n.registrationSuccessVerifyEmail,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    } else {
      // Handle different error types with appropriate messages
      _handleRegistrationError(result);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
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
    final compact = OnboardingStyle.isCompact(context);

    final eyebrowIcon =
        _showAddressForm ? Icons.home_rounded : Icons.person_add_alt_1_rounded;
    final eyebrowLabel = _showAddressForm ? 'STEP 2 OF 2' : 'STEP 1 OF 2';
    final heading =
        _showAddressForm ? l10n.addressTitle : l10n.register;
    final subtitle = _showAddressForm
        ? 'Almost there — set your delivery address'
        : 'Create your account to start shopping';

    return OnboardingShell(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: DesignTokens.paddingPageHorizontal.add(
          EdgeInsets.only(
            top: compact ? DesignTokens.space20 : DesignTokens.space32,
            bottom: DesignTokens.space40,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Illustration ──────────────────────────────────────
                OnboardingScaleIn(
                  animation: _animIllustration,
                  child: OnboardingFloatAnimation(
                    child: SignUpIllustration(
                      size: authIllustrationHeight(context),
                    ),
                  ),
                ),
                SizedBox(
                  height: compact
                      ? DesignTokens.space12
                      : DesignTokens.space16,
                ),
                // ── Eyebrow pill ──────────────────────────────────────
                OnboardingFadeSlide(
                  animation: _animEyebrow,
                  child: AuthEyebrow(
                    icon: eyebrowIcon,
                    label: eyebrowLabel,
                  ),
                ),
                const SizedBox(height: DesignTokens.space12),
                // ── Heading + subtitle ────────────────────────────────
                OnboardingFadeSlide(
                  animation: _animHeading,
                  child: Column(
                    children: [
                      Text(
                        heading,
                        style: OnboardingStyle.pageTitleStyle(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      Text(
                        subtitle,
                        style: OnboardingStyle.pageSubtitleStyle(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.space16),
                // ── Step progress ─────────────────────────────────────
                OnboardingFadeSlide(
                  animation: _animHeading,
                  child: OnboardingLinearProgress(
                    current: _showAddressForm ? 2 : 1,
                    total: 2,
                    label: eyebrowLabel,
                  ),
                ),
                SizedBox(
                  height: compact
                      ? DesignTokens.space16
                      : DesignTokens.space20,
                ),
                // ── Form card ─────────────────────────────────────────
                OnboardingFadeSlide(
                  animation: _animForm,
                  child: AuthFormCard(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: _showAddressForm
                          ? RegisterFormAddress(
                              key: const ValueKey('address_form'),
                              formData: _formData,
                              formKey: _formKeyAddress,
                              isLoading: _isLoading,
                              onSubmit: _submitRegistration,
                              onBack: () =>
                                  setState(() => _showAddressForm = false),
                            )
                          : RegisterFormUser(
                              key: const ValueKey('user_form'),
                              formData: _formData,
                              formKey: _formKeyUser,
                              gender: _gender,
                              birthday: _birthday,
                              onGenderChanged: (val) =>
                                  setState(() => _gender = val),
                              onBirthdayChanged: (val) =>
                                  setState(() => _birthday = val),
                              onNext: () {
                                if (_formKeyUser.currentState!.validate()) {
                                  setState(() => _showAddressForm = true);
                                }
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
