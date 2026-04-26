import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/authentication/auth_gate_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

/// Modernized onboarding screen with 4 pages (reduced from 8),
/// simple fade/slide animations, gradient CTA button, and improved step indicator.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  // Reduced to 4 pages by merging related content
  static const int _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pageCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingPersistenceService().setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withAlpha(13), // 5% opacity
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Step counter at top
              Padding(
                padding: const EdgeInsets.only(
                  top: DesignTokens.space16,
                  bottom: DesignTokens.space8,
                ),
                child: _StepIndicator(current: _index + 1, total: _pageCount),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pageCount,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    return _AnimatedPage(
                      key: ValueKey(i),
                      page: pages[i],
                      isActive: i == _index,
                    );
                  },
                ),
              ),
              // Bottom control bar
              Padding(
                padding: DesignTokens.paddingPageHorizontal.add(
                  const EdgeInsets.only(
                    bottom: DesignTokens.space24,
                    top: DesignTokens.space16,
                  ),
                ),
                child: _BottomControls(
                  currentIndex: _index,
                  pageCount: _pageCount,
                  onNext: _next,
                  onSkip: _finish,
                  nextLabel:
                      _index == _pageCount - 1
                          ? l10n.actionGetStarted
                          : l10n.actionNext,
                  skipLabel: l10n.actionSkip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_OnboardingPageData> _buildPages(AppLocalizations l10n) {
    return [
      // Page 1: Welcome + Community (merged title1+3, body1+3)
      _OnboardingPageData(
        icon: Icons.local_mall_rounded,
        title: l10n.onbTitle1,
        body: '${l10n.onbBody1}\n\n${l10n.onbBody3}',
      ),
      // Page 2: Shopping Experience (merged title2+4, body2+4)
      _OnboardingPageData(
        icon: Icons.search_rounded,
        title: l10n.onbTitle2,
        body: '${l10n.onbBody2}\n\n${l10n.onbBody4}',
      ),
      // Page 3: Features (merged title5+6, body5+6)
      _OnboardingPageData(
        icon: Icons.storefront_rounded,
        title: l10n.onbTitle5,
        body: '${l10n.onbBody5}\n\n${l10n.onbBody6}',
      ),
      // Page 4: Trust + Support (merged title7+8, body7+8)
      _OnboardingPageData(
        icon: Icons.verified_rounded,
        title: l10n.onbTitle7,
        body: '${l10n.onbBody7}\n\n${l10n.onbBody8}',
      ),
    ];
  }
}

/// Data class for onboarding page content
class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
  });
}

/// Animated page with fade and slide effects
class _AnimatedPage extends StatelessWidget {
  final _OnboardingPageData page;
  final bool isActive;

  const _AnimatedPage({super.key, required this.page, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: isActive ? Offset.zero : const Offset(0, 0.05),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: DesignTokens.paddingPageHorizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IconBubble(icon: page.icon),
              const SizedBox(height: DesignTokens.space32),
              Text(
                page.title,
                style: AppTypography.heading3.copyWith(
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(
                page.body,
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step indicator showing "Step X of Y" with progress bar
class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step $current of $total',
          style: AppTypography.small.copyWith(
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DesignTokens.space8),
        Container(
          width: 120,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(20),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: current / total,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF8A3D)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom controls with gradient CTA button
class _BottomControls extends StatelessWidget {
  final int currentIndex;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;
  final String skipLabel;

  const _BottomControls({
    required this.currentIndex,
    required this.pageCount,
    required this.onNext,
    required this.onSkip,
    required this.nextLabel,
    required this.skipLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Skip button (only on first pages, hidden on last)
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: currentIndex < pageCount - 1 ? 1.0 : 0.0,
          child: TextButton(
            onPressed: currentIndex < pageCount - 1 ? onSkip : null,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black45,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
              ),
            ),
            child: Text(skipLabel),
          ),
        ),
        const Spacer(),
        // Dot indicators (compact)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(pageCount, (i) {
            final active = i == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: active ? 20 : 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: active ? AppColors.primary : Colors.black.withAlpha(30),
              ),
            );
          }),
        ),
        const Spacer(),
        // Gradient CTA button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nextLabel,
                  style: AppTypography.bodyBold.copyWith(color: Colors.white),
                ),
                if (currentIndex < pageCount - 1) ...[
                  const SizedBox(width: DesignTokens.space8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient icon bubble with shadow
class _IconBubble extends StatelessWidget {
  final IconData icon;

  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFF8A3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77), // 30% opacity
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 40),
    );
  }
}
