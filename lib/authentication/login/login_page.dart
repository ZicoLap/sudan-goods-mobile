import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/login/login_form_data.dart';
import 'package:sudan_goods/authentication/widgets/auth_card.dart';
import 'package:sudan_goods/authentication/widgets/auth_eyebrow.dart';
import 'package:sudan_goods/authentication/login/login_form.dart';
import 'package:sudan_goods/authentication/widgets/auth_illustrations.dart';
import 'package:sudan_goods/onboarding/onboarding_animations.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formData = LoginFormData();
  late final AnimationController _stagger;

  static const _kDuration = Duration(milliseconds: 900);

  late final Animation<double> _animIllustration;
  late final Animation<double> _animEyebrow;
  late final Animation<double> _animHeading;
  late final Animation<double> _animForm;

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

  Animation<double> _interval(double begin, double end) =>
      CurvedAnimation(
        parent: _stagger,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  @override
  void dispose() {
    _stagger.dispose();
    _formData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = OnboardingStyle.isCompact(context);

    return OnboardingShell(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: DesignTokens.paddingPageHorizontal.add(
          EdgeInsets.only(
            top: compact ? DesignTokens.space24 : DesignTokens.space32,
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
                    child: SignInIllustration(
                      size: authIllustrationHeight(context),
                    ),
                  ),
                ),
                SizedBox(height: compact ? DesignTokens.space12 : DesignTokens.space16),
                // ── Eyebrow pill ──────────────────────────────────────
                OnboardingFadeSlide(
                  animation: _animEyebrow,
                  child: AuthEyebrow(
                    icon: Icons.lock_open_rounded,
                    label: 'SIGN IN',
                  ),
                ),
                const SizedBox(height: DesignTokens.space12),
                // ── Heading + subtitle ────────────────────────────────
                OnboardingFadeSlide(
                  animation: _animHeading,
                  child: Column(
                    children: [
                      Text(
                        'Welcome back',
                        style: OnboardingStyle.pageTitleStyle(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      Text(
                        'Sign in to continue your\nshopping journey',
                        style: OnboardingStyle.pageSubtitleStyle(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? DesignTokens.space20 : DesignTokens.space32),
                // ── Form card ─────────────────────────────────────────
                OnboardingFadeSlide(
                  animation: _animForm,
                  child: AuthFormCard(
                    child: LoginForm(formData: _formData),
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
