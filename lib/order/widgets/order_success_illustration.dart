import 'package:flutter/material.dart';
import 'package:sudan_goods/onboarding/onboarding_animations.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/order/order_assets.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Responsive 3D hero illustration for the order success screen.
class OrderSuccessIllustration extends StatelessWidget {
  const OrderSuccessIllustration({
    super.key,
    required this.confirmed,
    this.entryAnimation,
    this.enableFloat = true,
  });

  final bool confirmed;
  final Animation<double>? entryAnimation;
  final bool enableFloat;

  static double illustrationHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (OnboardingStyle.isVeryCompact(context)) return screenHeight * 0.24;
    if (OnboardingStyle.isCompact(context)) return screenHeight * 0.28;
    return screenHeight * 0.32;
  }

  @override
  Widget build(BuildContext context) {
    final height = illustrationHeight(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final assetPath =
        confirmed ? OrderAssets.successConfirmed : OrderAssets.successPending;
    final semanticsLabel = confirmed
        ? 'Order confirmed illustration'
        : 'Payment processing illustration';
    final fallbackIcon = confirmed
        ? Icons.check_circle_rounded
        : Icons.hourglass_top_rounded;

    Widget illustration = Semantics(
      label: semanticsLabel,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IllustrationBackdropBlob(variant: confirmed ? 0 : 2),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                ),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: !disableAnimations,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      fallbackIcon,
                      color: AppColors.primary,
                      size: 96,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (enableFloat && !disableAnimations) {
      illustration = OnboardingFloatAnimation(
        amplitude: 4,
        child: illustration,
      );
    }

    if (entryAnimation != null && !disableAnimations) {
      illustration = OnboardingScaleIn(
        animation: entryAnimation!,
        child: illustration,
      );
    }

    return illustration;
  }
}