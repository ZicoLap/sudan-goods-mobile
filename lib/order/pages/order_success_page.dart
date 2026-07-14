import 'package:flutter/material.dart';
import 'package:sudan_goods/onboarding/onboarding_animations.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/order/widgets/order_success_hero_header.dart';
import 'package:sudan_goods/order/widgets/order_success_illustration.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class OrderSuccessPage extends StatefulWidget {
  /// C1: true when the Firestore order record was found within the poll window
  /// (order placed successfully — not merchant confirmation status).
  /// false when we timed out (payment still went through, order will appear soon).
  final bool confirmed;

  const OrderSuccessPage({super.key, this.confirmed = true});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _entryController;
  bool _entryStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startEntryAnimation();
  }

  void _startEntryAnimation() {
    if (_entryStarted || !mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entryStarted = true;
      return;
    }

    _entryStarted = true;
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
  }

  @override
  void dispose() {
    _entryController?.dispose();
    super.dispose();
  }

  Animation<double> _staggerAnimation(int index) {
    const alwaysVisible = AlwaysStoppedAnimation<double>(1.0);
    final controller = _entryController;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    if (disableAnimations || controller == null) return alwaysVisible;

    return onboardingPageAnimation(controller, index, count: 4);
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    const alwaysVisible = AlwaysStoppedAnimation<double>(1.0);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final controller = _entryController;
    final compact = OnboardingStyle.isCompact(context);

    final illustrationAnim = disableAnimations || controller == null
        ? alwaysVisible
        : _staggerAnimation(0);
    final titleAnim = disableAnimations || controller == null
        ? alwaysVisible
        : _staggerAnimation(1);
    final bodyAnim = disableAnimations || controller == null
        ? alwaysVisible
        : _staggerAnimation(2);
    final buttonAnim = disableAnimations || controller == null
        ? alwaysVisible
        : _staggerAnimation(3);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OrderSuccessHeroHeader(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.space24,
                  vertical: compact
                      ? DesignTokens.space16
                      : DesignTokens.space24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OrderSuccessIllustration(
                      confirmed: widget.confirmed,
                      entryAnimation: illustrationAnim,
                    ),
                    SizedBox(
                      height: compact
                          ? DesignTokens.space20
                          : DesignTokens.space24,
                    ),
                    OnboardingFadeSlide(
                      animation: titleAnim,
                      offset: 20,
                      child: Column(
                        children: [
                          Text(
                            widget.confirmed
                                ? 'Order placed!'
                                : 'Payment received!',
                            textAlign: TextAlign.center,
                            style: OnboardingStyle.pageTitleStyle(context),
                          ),
                          SizedBox(
                            height: compact
                                ? DesignTokens.space8
                                : DesignTokens.space10,
                          ),
                          const Center(child: OnboardingAccentLine(width: 44)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: compact
                          ? DesignTokens.space12
                          : DesignTokens.space16,
                    ),
                    OnboardingFadeSlide(
                      animation: bodyAnim,
                      offset: 16,
                      child: Text(
                        widget.confirmed
                            ? 'Your order has been placed and will appear in your Orders tab shortly.'
                            : 'Your payment was received. Your order is being finalised and will appear in your Orders tab shortly.',
                        textAlign: TextAlign.center,
                        style: OnboardingStyle.pageSubtitleStyle(context),
                      ),
                    ),
                    SizedBox(
                      height: compact
                          ? DesignTokens.space24
                          : DesignTokens.space32,
                    ),
                    OnboardingFadeSlide(
                      animation: buttonAnim,
                      offset: 12,
                      child: OnboardingPrimaryButton(
                        label: 'Back to Home',
                        onPressed: _goHome,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
