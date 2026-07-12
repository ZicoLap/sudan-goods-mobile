import 'package:flutter/material.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Shared visual constants and responsive helpers for first-run flows.
class OnboardingStyle {
  OnboardingStyle._();

  static const Color gradientAccent = Color(0xFFFF8A3D);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [AppColors.primary, gradientAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 680;

  static bool isVeryCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 600;

  static double heroIconSize(BuildContext context) =>
      isVeryCompact(context) ? 56 : (isCompact(context) ? 64 : 80);

  static double pageIconSize(BuildContext context) =>
      isVeryCompact(context) ? 64 : (isCompact(context) ? 72 : 88);

  static double iconGlyphSize(BuildContext context) =>
      isVeryCompact(context) ? 28 : (isCompact(context) ? 32 : 40);

  static double illustrationMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (isVeryCompact(context)) return screenHeight * 0.34;
    if (isCompact(context)) return screenHeight * 0.38;
    return screenHeight * 0.42;
  }

  static TextStyle pageSubtitleStyle(BuildContext context) {
    final base =
        isCompact(context) ? AppTypography.body : AppTypography.bodyLarge;
    return base.copyWith(
      color: AppColors.text.withValues(alpha: 0.58),
      height: 1.45,
    );
  }

  static TextStyle pageTitleStyle(BuildContext context) {
    final base =
        isCompact(context)
            ? AppTypography.heading4
            : AppTypography.heading3;
    return base.copyWith(
      color: AppColors.text,
      letterSpacing: -0.5,
    );
  }

  static TextStyle pageBodyStyle(BuildContext context) {
    final base =
        isCompact(context) ? AppTypography.body : AppTypography.bodyLarge;
    return base.copyWith(
      color: AppColors.text.withValues(alpha: 0.62),
      height: 1.55,
    );
  }

  static BoxDecoration screenBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFFFFF9F5),
          Colors.white,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static List<BoxShadow> brandShadow({double opacity = 0.28}) => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Gradient-backed scaffold used by language picker and onboarding.
class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.body,
    this.topBar,
  });

  final Widget body;
  final Widget? topBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: OnboardingStyle.screenBackground(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (topBar != null) topBar!,
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// Brand mark used on the language picker.
class OnboardingBrandMark extends StatelessWidget {
  const OnboardingBrandMark({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? OnboardingStyle.heroIconSize(context);
    final glyph = OnboardingStyle.iconGlyphSize(context);

    return Semantics(
      label: 'Sudan Goods',
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: OnboardingStyle.brandGradient,
          boxShadow: OnboardingStyle.brandShadow(),
        ),
        child: Icon(
          Icons.shopping_bag_rounded,
          size: glyph,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Circular icon container for onboarding pages.
class OnboardingPageIcon extends StatelessWidget {
  const OnboardingPageIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dimension = OnboardingStyle.pageIconSize(context);
    final glyph = OnboardingStyle.iconGlyphSize(context);

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: OnboardingStyle.brandGradient,
        boxShadow: OnboardingStyle.brandShadow(),
      ),
      child: Icon(icon, color: Colors.white, size: glyph),
    );
  }
}

/// Linear progress indicator for onboarding steps.
class OnboardingLinearProgress extends StatelessWidget {
  const OnboardingLinearProgress({
    super.key,
    required this.current,
    required this.total,
    required this.label,
  });

  final int current;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final progress = current / total;

    return Semantics(
      label: label,
      value: '${(progress * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.small.copyWith(
              color: AppColors.text.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.text.withValues(alpha: 0.08),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page dot indicators.
class OnboardingPageDots extends StatelessWidget {
  const OnboardingPageDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${currentIndex + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final active = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: active ? 22 : 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              color:
                  active
                      ? AppColors.primary
                      : AppColors.text.withValues(alpha: 0.18),
            ),
          );
        }),
      ),
    );
  }
}

/// Primary CTA used across onboarding flows.
class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showTrailingIcon = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showTrailingIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          ),
          elevation: 0,
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (showTrailingIcon) ...[
                      const SizedBox(width: DesignTokens.space8),
                      Icon(
                        isRtl ? Icons.arrow_back : Icons.arrow_forward,
                        size: 18,
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}

/// Branded loading state for app start gate.
class OnboardingLoadingView extends StatelessWidget {
  const OnboardingLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: OnboardingStyle.illustrationMaxHeight(context) * 0.55,
              child: OnboardingIllustration(
                assetPath: OnboardingAssets.languageWelcome,
                semanticsLabel: 'Sudan Goods',
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft gradient blob rendered behind onboarding illustrations.
class IllustrationBackdropBlob extends StatelessWidget {
  const IllustrationBackdropBlob({
    super.key,
    this.variant = 0,
  });

  /// Optional subtle tint shift per page (0–3).
  final int variant;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final blobSize = width * 0.78;
    final secondaryOffset =
        switch (variant % 4) {
          0 => const Offset(-0.08, -0.04),
          1 => const Offset(0.06, -0.02),
          2 => const Offset(-0.04, 0.05),
          _ => const Offset(0.05, 0.04),
        };

    return IgnorePointer(
      child: SizedBox(
        width: blobSize,
        height: blobSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            _BlobCircle(
              diameter: blobSize * 0.92,
              colors: [
                AppColors.primary.withValues(alpha: 0.16),
                AppColors.primary.withValues(alpha: 0.0),
              ],
            ),
            Transform.translate(
              offset: Offset(
                secondaryOffset.dx * blobSize,
                secondaryOffset.dy * blobSize,
              ),
              child: _BlobCircle(
                diameter: blobSize * 0.62,
                colors: [
                  OnboardingStyle.gradientAccent.withValues(alpha: 0.12),
                  OnboardingStyle.gradientAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
            _BlobCircle(
              diameter: blobSize * 0.48,
              colors: [
                const Color(0xFFFFF0E6).withValues(alpha: 0.55),
                const Color(0xFFFFF0E6).withValues(alpha: 0.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlobCircle extends StatelessWidget {
  const _BlobCircle({
    required this.diameter,
    required this.colors,
  });

  final double diameter;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

/// Responsive illustration hero for onboarding screens.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.assetPath,
    required this.semanticsLabel,
    this.maxHeight,
    this.backdropVariant = 0,
  });

  final String assetPath;
  final String semanticsLabel;
  final double? maxHeight;
  final int backdropVariant;

  @override
  Widget build(BuildContext context) {
    final height = maxHeight ?? OnboardingStyle.illustrationMaxHeight(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: semanticsLabel,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IllustrationBackdropBlob(variant: backdropVariant),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space8,
              ),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                gaplessPlayback: !disableAnimations,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.45),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
