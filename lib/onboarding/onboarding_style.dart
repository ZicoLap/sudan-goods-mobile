import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sudan_goods/onboarding/onboarding_animations.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Shared visual constants and responsive helpers for first-run flows.
class OnboardingStyle {
  OnboardingStyle._();

  static const Color gradientAccent = Color(0xFFFF8A3D);
  static const Color surfaceWarm = Color(0xFFFFF9F5);
  static const Color surfaceMuted = Color(0xFFFFF0E6);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [AppColors.primary, gradientAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGradient = LinearGradient(
    colors: [
      Color(0xFFFFF9F5),
      Color(0xFFFFF3EB),
      Colors.white,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
  );

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 680;

  static bool isVeryCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 600;

  static double illustrationMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (isVeryCompact(context)) return screenHeight * 0.32;
    if (isCompact(context)) return screenHeight * 0.36;
    return screenHeight * 0.40;
  }

  static TextStyle pageSubtitleStyle(BuildContext context) {
    final base =
        isCompact(context) ? AppTypography.body : AppTypography.bodyLarge;
    return base.copyWith(
      color: AppColors.text.withValues(alpha: 0.68),
      fontWeight: FontWeight.w500,
      height: 1.5,
    );
  }

  static TextStyle pageTitleStyle(BuildContext context) {
    final base =
        isCompact(context)
            ? AppTypography.heading4
            : AppTypography.heading3;
    return base.copyWith(
      color: AppColors.text,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.15,
    );
  }

  static TextStyle languagePickerTitleStyle(BuildContext context) {
    final base =
        isCompact(context)
            ? AppTypography.heading4
            : AppTypography.heading2;
    return base.copyWith(
      color: AppColors.text,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.12,
    );
  }

  static TextStyle languagePickerSubtitleStyle(BuildContext context) {
    return AppTypography.bodyLarge.copyWith(
      color: AppColors.text.withValues(alpha: 0.65),
      fontWeight: FontWeight.w600,
      height: 1.45,
    );
  }

  static TextStyle languageTileTitleStyle(BuildContext context) {
    return AppTypography.heading5.copyWith(
      color: AppColors.text,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
  }

  static TextStyle languageTileSubtitleStyle(BuildContext context) {
    return AppTypography.body.copyWith(
      color: AppColors.text.withValues(alpha: 0.55),
      fontWeight: FontWeight.w500,
      height: 1.3,
    );
  }

  static TextStyle pageEyebrowStyle(BuildContext context) {
    return AppTypography.smallBold.copyWith(
      color: AppColors.primary,
      letterSpacing: 1.2,
    );
  }

  static BoxDecoration screenBackground() {
    return const BoxDecoration(gradient: meshGradient);
  }

  static List<BoxShadow> brandShadow({double opacity = 0.24}) => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: opacity),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> cardShadow({bool selected = false}) => [
    BoxShadow(
      color:
          selected
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.06),
      blurRadius: selected ? 20 : 12,
      offset: Offset(0, selected ? 8 : 4),
    ),
  ];
}

/// Gradient-backed scaffold with ambient decorative orbs.
class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.body,
    this.topBar,
    this.bottomBar,
    this.showAmbientOrbs = true,
  });

  final Widget body;
  final Widget? topBar;
  final Widget? bottomBar;
  final bool showAmbientOrbs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: OnboardingStyle.screenBackground(),
        child: Stack(
          children: [
            if (showAmbientOrbs) const _AmbientOrbs(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (topBar != null) topBar!,
                  Expanded(child: body),
                  if (bottomBar != null) bottomBar!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientOrbs extends StatelessWidget {
  const _AmbientOrbs();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -size.width * 0.18,
            right: -size.width * 0.12,
            child: _Orb(
              diameter: size.width * 0.55,
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            top: size.height * 0.22,
            left: -size.width * 0.22,
            child: _Orb(
              diameter: size.width * 0.48,
              color: OnboardingStyle.gradientAccent.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: size.height * 0.08,
            right: -size.width * 0.08,
            child: _Orb(
              diameter: size.width * 0.36,
              color: OnboardingStyle.surfaceMuted.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

/// Compact brand mark for the language picker header.
class OnboardingBrandMark extends StatelessWidget {
  const OnboardingBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = OnboardingStyle.isCompact(context);
    final size = compact ? 44.0 : 52.0;

    return Semantics(
      label: 'Sudan Goods',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: OnboardingStyle.brandGradient,
          boxShadow: OnboardingStyle.brandShadow(opacity: 0.20),
        ),
        child: const Icon(
          Icons.shopping_bag_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

/// Animated step progress bar for onboarding.
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
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.text.withValues(alpha: 0.08),
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.small.copyWith(
                    color: AppColors.text.withValues(alpha: 0.50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Modern pill-style page indicators.
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
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: active ? 28 : 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              gradient:
                  active
                      ? OnboardingStyle.brandGradient
                      : null,
              color:
                  active
                      ? null
                      : AppColors.text.withValues(alpha: 0.14),
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
    final enabled = onPressed != null && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
        boxShadow:
            enabled
                ? OnboardingStyle.brandShadow(opacity: 0.22)
                : const [],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.text.withValues(alpha: 0.10),
            disabledForegroundColor: AppColors.text.withValues(alpha: 0.35),
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
                            color:
                                enabled
                                    ? Colors.white
                                    : AppColors.text.withValues(alpha: 0.35),
                            fontSize: DesignTokens.fontSizeBodyLarge,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (showTrailingIcon) ...[
                        const SizedBox(width: DesignTokens.space8),
                        Icon(
                          isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
        ),
      ),
    );
  }
}

/// Text-style skip action for onboarding top bar.
class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.text.withValues(alpha: 0.55),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space12,
          vertical: DesignTokens.space8,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.bodyBold.copyWith(
          color: AppColors.text.withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
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
              child: OnboardingFloatAnimation(
                child: OnboardingIllustration(
                  assetPath: OnboardingAssets.languageWelcome,
                  semanticsLabel: 'Sudan Goods',
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: AppColors.primary.withValues(alpha: 0.85),
              ),
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

  final int variant;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final blobSize = width * 0.82;
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
              diameter: blobSize * 0.94,
              colors: [
                AppColors.primary.withValues(alpha: 0.14),
                AppColors.primary.withValues(alpha: 0.0),
              ],
            ),
            Transform.translate(
              offset: Offset(
                secondaryOffset.dx * blobSize,
                secondaryOffset.dy * blobSize,
              ),
              child: _BlobCircle(
                diameter: blobSize * 0.64,
                colors: [
                  OnboardingStyle.gradientAccent.withValues(alpha: 0.10),
                  OnboardingStyle.gradientAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
            _BlobCircle(
              diameter: blobSize * 0.50,
              colors: [
                OnboardingStyle.surfaceMuted.withValues(alpha: 0.70),
                OnboardingStyle.surfaceMuted.withValues(alpha: 0.0),
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
        gradient: RadialGradient(colors: colors, stops: const [0.0, 1.0]),
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
    this.enableFloat = false,
    this.showBackdrop = true,
  });

  final String assetPath;
  final String semanticsLabel;
  final double? maxHeight;
  final int backdropVariant;
  final bool enableFloat;
  final bool showBackdrop;

  @override
  Widget build(BuildContext context) {
    final height = maxHeight ?? OnboardingStyle.illustrationMaxHeight(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    Widget illustration = Semantics(
      label: semanticsLabel,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (showBackdrop)
              IllustrationBackdropBlob(variant: backdropVariant),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                ),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
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
            ),
          ],
        ),
      ),
    );

    if (enableFloat && !disableAnimations) {
      illustration = OnboardingFloatAnimation(child: illustration);
    }

    return illustration;
  }
}

/// Selectable language tile for the first-run language picker.
class OnboardingLanguageTile extends StatelessWidget {
  const OnboardingLanguageTile({
    super.key,
    required this.code,
    required this.nativeLabel,
    required this.isSelected,
    required this.onTap,
    this.secondaryLabel,
    this.isDisabled = false,
  });

  final String code;
  final String nativeLabel;
  final String? secondaryLabel;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final isArabic = code == 'ar';

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !isDisabled,
      label: nativeLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      OnboardingStyle.gradientAccent.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : Colors.white,
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : AppColors.text.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: OnboardingStyle.cardShadow(selected: isSelected),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    OnboardingStyle.isCompact(context)
                        ? DesignTokens.space12
                        : DesignTokens.space16,
                vertical: DesignTokens.space16,
              ),
              child: Row(
                children: [
                  Container(
                    width: OnboardingStyle.isCompact(context) ? 44 : 48,
                    height: OnboardingStyle.isCompact(context) ? 44 : 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          isSelected
                              ? OnboardingStyle.brandGradient
                              : LinearGradient(
                                colors: [
                                  AppColors.text.withValues(alpha: 0.06),
                                  AppColors.text.withValues(alpha: 0.04),
                                ],
                              ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isArabic ? 'ع' : 'EN',
                      style: AppTypography.bodyBold.copyWith(
                        color:
                            isSelected
                                ? Colors.white
                                : AppColors.text.withValues(alpha: 0.65),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nativeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OnboardingStyle.languageTileTitleStyle(context),
                        ),
                        if (secondaryLabel != null) ...[
                          const SizedBox(height: DesignTokens.space4),
                          Text(
                            secondaryLabel!,
                            style: OnboardingStyle.languageTileSubtitleStyle(
                              context,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child:
                        isSelected
                            ? Icon(
                              Icons.check_circle_rounded,
                              key: const ValueKey('selected'),
                              color: AppColors.primary,
                              size: 24,
                            )
                            : Icon(
                              Icons.circle_outlined,
                              key: const ValueKey('unselected'),
                              color: AppColors.text.withValues(alpha: 0.20),
                              size: 24,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative accent line under headings.
class OnboardingAccentLine extends StatelessWidget {
  const OnboardingAccentLine({super.key, this.width = 40});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
        gradient: OnboardingStyle.brandGradient,
      ),
    );
  }
}

/// Shared page route transition for first-run flows.
Route<T> onboardingFadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 380),
  );
}

/// Computes a staggered animation for onboarding page content.
Animation<double> onboardingPageAnimation(
  Animation<double> parent,
  int index, {
  int count = 3,
}) {
  final start = (index / count) * 0.35;
  final end = math.min(start + 0.65, 1.0);
  return CurvedAnimation(
    parent: parent,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );
}
