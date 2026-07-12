import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/onboarding/models/onboarding_page.dart';
import 'package:sudan_goods/onboarding/onboarding_animations.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/authentication/auth_gate_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Premium illustration-led onboarding walkthrough.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.persistenceService,
    this.nextScreen,
  });

  final OnboardingPersistenceService? persistenceService;
  final Widget? nextScreen;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _isFinishing = false;

  static const int _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLastPage => _index >= _pageCount - 1;

  Future<void> _finish() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    HapticFeedback.mediumImpact();

    try {
      final persistence =
          widget.persistenceService ?? OnboardingPersistenceService();
      await persistence.setHasSeenOnboarding(true);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        onboardingFadeRoute(widget.nextScreen ?? const AuthGate()),
      );
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  void _next() {
    if (_isFinishing) return;

    if (_index < _pageCount - 1) {
      HapticFeedback.selectionClick();
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  List<OnboardingPage> _buildPages(AppLocalizations l10n) {
    return [
      OnboardingPage(
        assetPath: OnboardingAssets.welcome,
        title: l10n.onbTitle1,
        subtitle: l10n.onbSubtitle1,
        semanticsLabel: l10n.onbIllustrationWelcome,
        backdropVariant: 0,
      ),
      OnboardingPage(
        assetPath: OnboardingAssets.order,
        title: l10n.onbTitle2,
        subtitle: l10n.onbSubtitle2,
        semanticsLabel: l10n.onbIllustrationOrder,
        backdropVariant: 1,
      ),
      OnboardingPage(
        assetPath: OnboardingAssets.discover,
        title: l10n.onbTitle5,
        subtitle: l10n.onbSubtitle3,
        semanticsLabel: l10n.onbIllustrationDiscover,
        backdropVariant: 2,
      ),
      OnboardingPage(
        assetPath: OnboardingAssets.start,
        title: l10n.onbTitle7,
        subtitle: l10n.onbSubtitle4,
        semanticsLabel: l10n.onbIllustrationStart,
        backdropVariant: 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);
    final compact = OnboardingStyle.isCompact(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return OnboardingShell(
      topBar: Padding(
        padding: DesignTokens.paddingPageHorizontal.add(
          EdgeInsets.only(
            top: compact ? DesignTokens.space4 : DesignTokens.space8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OnboardingLinearProgress(
                current: _index + 1,
                total: _pageCount,
                label: l10n.onbStepProgress(_index + 1, _pageCount),
              ),
            ),
            if (!_isLastPage)
              OnboardingSkipButton(
                label: l10n.actionSkip,
                onPressed: _isFinishing ? null : _finish,
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pageCount,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                return _OnboardingPageView(
                  page: pages[i],
                  pageIndex: i,
                  isActive: _index == i,
                );
              },
            ),
          ),
          Padding(
            padding: DesignTokens.paddingPageHorizontal.add(
              EdgeInsets.only(
                top: DesignTokens.space8,
                bottom: compact ? DesignTokens.space16 : DesignTokens.space24,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration:
                      disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 280),
                  child: OnboardingPageDots(
                    key: ValueKey(_index),
                    count: _pageCount,
                    currentIndex: _index,
                  ),
                ),
                const SizedBox(height: DesignTokens.space20),
                OnboardingPrimaryButton(
                  label: _isLastPage ? l10n.actionGetStarted : l10n.actionNext,
                  onPressed: _next,
                  showTrailingIcon: !_isLastPage,
                  isLoading: _isFinishing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatefulWidget {
  const _OnboardingPageView({
    required this.page,
    required this.pageIndex,
    required this.isActive,
  });

  final OnboardingPage page;
  final int pageIndex;
  final bool isActive;

  @override
  State<_OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<_OnboardingPageView>
    with SingleTickerProviderStateMixin {
  AnimationController? _entryController;
  bool _entryStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isActive && !_entryStarted) {
      _startEntryAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant _OnboardingPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _entryStarted = false;
      _startEntryAnimation();
    }
  }

  void _startEntryAnimation() {
    if (_entryStarted || !widget.isActive) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entryStarted = true;
      return;
    }

    _entryStarted = true;
    _entryController?.dispose();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    )..forward();
  }

  @override
  void dispose() {
    _entryController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = OnboardingStyle.isCompact(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final controller = _entryController;
    final alwaysVisible = AlwaysStoppedAnimation<double>(1);

    final illustrationAnim =
        disableAnimations || controller == null
            ? alwaysVisible
            : onboardingPageAnimation(controller, 0);
    final titleAnim =
        disableAnimations || controller == null
            ? alwaysVisible
            : onboardingPageAnimation(controller, 1);
    final subtitleAnim =
        disableAnimations || controller == null
            ? alwaysVisible
            : onboardingPageAnimation(controller, 2);

    Widget content = Padding(
      padding: DesignTokens.paddingPageHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: compact ? DesignTokens.space4 : DesignTokens.space8,
          ),
          Expanded(
            child: Center(
              child: OnboardingScaleIn(
                animation: illustrationAnim,
                child: OnboardingIllustration(
                  assetPath: widget.page.assetPath,
                  semanticsLabel: widget.page.semanticsLabel,
                  backdropVariant: widget.page.backdropVariant,
                  enableFloat: true,
                ),
              ),
            ),
          ),
          OnboardingFadeSlide(
            animation: titleAnim,
            child: Text(
              widget.page.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: OnboardingStyle.pageTitleStyle(context),
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          OnboardingFadeSlide(
            animation: subtitleAnim,
            child: Text(
              widget.page.subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: OnboardingStyle.pageSubtitleStyle(context),
            ),
          ),
          SizedBox(
            height: compact ? DesignTokens.space8 : DesignTokens.space12,
          ),
        ],
      ),
    );

    if (disableAnimations) return content;

    return content;
  }
}