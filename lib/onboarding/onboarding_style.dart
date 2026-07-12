import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sudan_goods/onboarding/onboarding_animations.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Shared visual constants and responsive helpers for first-run flows.
class OnboardingStyle {
  OnboardingStyle._();

  static const Color gradientAccent = Color(0xFFFF7A20);
  static const Color gradientDeep  = Color(0xFFE85500);
  static const Color surfaceWarm   = Color(0xFFFFF8F3);
  static const Color surfaceMuted  = Color(0xFFFFF0E5);
  static const Color cardSurface   = Color(0xFFFFFFFF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [gradientDeep, AppColors.primary, gradientAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient brandGradientSimple = LinearGradient(
    colors: [AppColors.primary, gradientAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGradient = LinearGradient(
    colors: [
      Color(0xFFFFF9F4),
      Color(0xFFFFF4EC),
      Color(0xFFFFFBF8),
      Colors.white,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.30, 0.65, 1.0],
  );

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 680;

  static bool isVeryCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 600;

  static double illustrationMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (isVeryCompact(context)) return screenHeight * 0.30;
    if (isCompact(context))     return screenHeight * 0.34;
    return screenHeight * 0.40;
  }

  static TextStyle pageSubtitleStyle(BuildContext context) {
    final base =
        isCompact(context) ? AppTypography.body : AppTypography.bodyLarge;
    return base.copyWith(
      color: AppColors.text.withValues(alpha: 0.60),
      fontWeight: FontWeight.w500,
      height: 1.6,
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
      letterSpacing: -0.8,
      height: 1.12,
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
      letterSpacing: -0.8,
      height: 1.10,
    );
  }

  static TextStyle languagePickerSubtitleStyle(BuildContext context) {
    return AppTypography.bodyLarge.copyWith(
      color: AppColors.text.withValues(alpha: 0.58),
      fontWeight: FontWeight.w500,
      height: 1.55,
    );
  }

  static TextStyle languageTileTitleStyle(BuildContext context) {
    return AppTypography.heading5.copyWith(
      color: AppColors.text,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.2,
    );
  }

  static TextStyle languageTileSubtitleStyle(BuildContext context) {
    return AppTypography.body.copyWith(
      color: AppColors.text.withValues(alpha: 0.48),
      fontWeight: FontWeight.w500,
      height: 1.3,
    );
  }

  static TextStyle pageEyebrowStyle(BuildContext context) {
    return AppTypography.smallBold.copyWith(
      color: AppColors.primary,
      letterSpacing: 1.4,
    );
  }

  static BoxDecoration screenBackground() {
    return const BoxDecoration(gradient: meshGradient);
  }

  static List<BoxShadow> brandShadow({double opacity = 0.28}) => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: opacity),
      blurRadius: 28,
      spreadRadius: -4,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> cardShadow({bool selected = false}) => [
    if (selected) ...[
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.20),
        blurRadius: 24,
        spreadRadius: -2,
        offset: const Offset(0, 8),
      ),
    ] else ...[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 16,
        spreadRadius: -2,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  ];

  static List<BoxShadow> buttonShadow({bool enabled = true}) => enabled
      ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ]
      : const [];
}

/// Gradient-backed scaffold with ambient decorative blobs.
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
          // Top-right warm orb
          Positioned(
            top: -size.width * 0.20,
            right: -size.width * 0.15,
            child: _GradientOrb(
              diameter: size.width * 0.70,
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                OnboardingStyle.gradientAccent.withValues(alpha: 0.06),
                Colors.transparent,
              ],
            ),
          ),
          // Mid-left accent orb
          Positioned(
            top: size.height * 0.28,
            left: -size.width * 0.25,
            child: _GradientOrb(
              diameter: size.width * 0.55,
              colors: [
                OnboardingStyle.gradientAccent.withValues(alpha: 0.09),
                Colors.transparent,
              ],
            ),
          ),
          // Bottom-right soft glow
          Positioned(
            bottom: size.height * 0.04,
            right: -size.width * 0.10,
            child: _GradientOrb(
              diameter: size.width * 0.42,
              colors: [
                AppColors.primary.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientOrb extends StatelessWidget {
  const _GradientOrb({required this.diameter, required this.colors});

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
          colors: colors.length == 1
              ? [...colors, Colors.transparent]
              : colors,
          stops: colors.length == 3
              ? const [0.0, 0.55, 1.0]
              : const [0.0, 1.0],
        ),
      ),
    );
  }
}

/// Premium brand mark — gradient pill with icon + wordmark.
class OnboardingBrandMark extends StatelessWidget {
  const OnboardingBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = OnboardingStyle.isCompact(context);
    final iconSize = compact ? 40.0 : 48.0;

    return Semantics(
      label: 'Sudan Goods',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: OnboardingStyle.brandGradient,
              boxShadow: OnboardingStyle.brandShadow(opacity: 0.22),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: compact ? 20 : 24,
            ),
          ),
          const SizedBox(width: DesignTokens.space10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sudan',
                style: AppTypography.heading6.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  letterSpacing: -0.3,
                  fontSize: compact ? 15 : 17,
                ),
              ),
              Text(
                'Goods',
                style: AppTypography.heading6.copyWith(
                  foreground: Paint()
                    ..shader = OnboardingStyle.brandGradientSimple.createShader(
                      const Rect.fromLTWH(0, 0, 60, 20),
                    ),
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  letterSpacing: -0.3,
                  fontSize: compact ? 15 : 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Segmented step-pill progress indicator for onboarding.
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
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: AppColors.text.withValues(alpha: 0.07),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.space10),
          Text(
            '$current/$total',
            maxLines: 1,
            style: AppTypography.small.copyWith(
              color: AppColors.text.withValues(alpha: 0.42),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Elongated pill page-indicator dots.
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
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3.5),
            height: 7,
            width: active ? 32 : 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              gradient: active ? OnboardingStyle.brandGradientSimple : null,
              color: active ? null : AppColors.text.withValues(alpha: 0.12),
            ),
          );
        }),
      ),
    );
  }
}

/// Primary gradient CTA button.
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

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: Stack(
        children: [
          // Gradient container (always rendered for smooth disable animation)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 1.0 : 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                gradient: OnboardingStyle.brandGradient,
                boxShadow: OnboardingStyle.buttonShadow(enabled: enabled),
              ),
            ),
          ),
          // Disabled surface
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 0.0 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                color: AppColors.text.withValues(alpha: 0.09),
              ),
            ),
          ),
          // Ink + content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Center(
                child: isLoading
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
                                color: enabled
                                    ? Colors.white
                                    : AppColors.text.withValues(alpha: 0.35),
                                fontSize: DesignTokens.fontSizeBodyLarge,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          if (showTrailingIcon) ...[
                            const SizedBox(width: DesignTokens.space8),
                            Icon(
                              isRtl
                                  ? Icons.arrow_back_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 20,
                              color: enabled
                                  ? Colors.white
                                  : AppColors.text.withValues(alpha: 0.35),
                            ),
                          ],
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

/// Refined skip button with pill background on hover.
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
        foregroundColor: AppColors.text.withValues(alpha: 0.48),
        overlayColor: AppColors.text.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space12,
          vertical: DesignTokens.space8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.bodyBold.copyWith(
          color: AppColors.text.withValues(alpha: 0.48),
          fontWeight: FontWeight.w600,
          fontSize: 14,
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
              height: OnboardingStyle.illustrationMaxHeight(context) * 0.60,
              child: OnboardingFloatAnimation(
                child: OnboardingIllustration(
                  assetPath: OnboardingAssets.languageWelcome,
                  semanticsLabel: 'Sudan Goods',
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.primary.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Layered radial-gradient blob rendered behind onboarding illustrations.
class IllustrationBackdropBlob extends StatelessWidget {
  const IllustrationBackdropBlob({super.key, this.variant = 0});

  final int variant;

  static const List<List<Color>> _variantPalettes = [
    [Color(0x1AF36805), Color(0x0DFF8A3D)],
    [Color(0x14FF7020), Color(0x0AE85500)],
    [Color(0x18F36805), Color(0x0CFF9A50)],
    [Color(0x12E85500), Color(0x0EFF7A20)],
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final blobSize = width * 0.80;
    final palette = _variantPalettes[variant % _variantPalettes.length];
    final secondaryOffset =
        switch (variant % 4) {
          0 => const Offset(-0.07, -0.03),
          1 => const Offset(0.07, -0.03),
          2 => const Offset(-0.05, 0.06),
          _ => const Offset(0.06, 0.04),
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
              diameter: blobSize * 0.90,
              colors: [palette[0], Colors.transparent],
            ),
            Transform.translate(
              offset: Offset(
                secondaryOffset.dx * blobSize,
                secondaryOffset.dy * blobSize,
              ),
              child: _BlobCircle(
                diameter: blobSize * 0.62,
                colors: [palette[1], Colors.transparent],
              ),
            ),
            _BlobCircle(
              diameter: blobSize * 0.45,
              colors: [
                OnboardingStyle.surfaceMuted.withValues(alpha: 0.65),
                Colors.transparent,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlobCircle extends StatelessWidget {
  const _BlobCircle({required this.diameter, required this.colors});

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
                  horizontal: DesignTokens.space12,
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
                      color: AppColors.primary.withValues(alpha: 0.40),
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

/// Premium selectable language card for the first-run language picker.
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

  static const _flagEmoji = {'en': '🇬🇧', 'ar': '🇸🇩'};
  static const _languageTag = {'en': 'EN', 'ar': 'عر'};

  @override
  Widget build(BuildContext context) {
    final flag = _flagEmoji[code] ?? '🌐';
    final tag  = _languageTag[code] ?? code.toUpperCase();
    final compact = OnboardingStyle.isCompact(context);
    final avatarSize = compact ? 52.0 : 58.0;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !isDisabled,
      label: nativeLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          color: isSelected ? null : OnboardingStyle.cardSurface,
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.07),
                    OnboardingStyle.gradientAccent.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.black.withValues(alpha: 0.07),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: OnboardingStyle.cardShadow(selected: isSelected),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            splashColor: AppColors.primary.withValues(alpha: 0.06),
            highlightColor: AppColors.primary.withValues(alpha: 0.03),
            child: Directionality(
              textDirection: code == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? DesignTokens.space14 : DesignTokens.space16,
                vertical: compact ? DesignTokens.space14 : DesignTokens.space18,
              ),
              child: Row(
                children: [
                  // Flag avatar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: isSelected
                          ? OnboardingStyle.brandGradient
                          : null,
                      color: isSelected
                          ? null
                          : Colors.black.withValues(alpha: 0.04),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          flag,
                          style: TextStyle(
                            fontSize: compact ? 22 : 26,
                            height: 1,
                          ),
                        ),
                        // Language tag badge in bottom-right
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.92)
                                  : AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.captionBold.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.text.withValues(alpha: 0.60),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space14),
                  // Labels
                  Expanded(
                    child: Directionality(
                      textDirection: code == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nativeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OnboardingStyle.languageTileTitleStyle(context),
                          ),
                          if (secondaryLabel != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              secondaryLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OnboardingStyle.languageTileSubtitleStyle(
                                context,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space8),
                  // Selection indicator
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: isSelected
                        ? Container(
                            key: const ValueKey('selected'),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: OnboardingStyle.brandGradientSimple,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.30),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
                        : Container(
                            key: const ValueKey('unselected'),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.14),
                                width: 1.5,
                              ),
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

/// Decorative gradient accent pill under headings.
class OnboardingAccentLine extends StatelessWidget {
  const OnboardingAccentLine({super.key, this.width = 36});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
        gradient: OnboardingStyle.brandGradientSimple,
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
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

/// Computes a staggered animation for onboarding page content.
Animation<double> onboardingPageAnimation(
  Animation<double> parent,
  int index, {
  int count = 3,
}) {
  final start = (index / count) * 0.30;
  final end = math.min(start + 0.70, 1.0);
  return CurvedAnimation(
    parent: parent,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );
}
