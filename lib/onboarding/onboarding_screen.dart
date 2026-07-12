import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/onboarding/models/onboarding_page.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/authentication/auth_gate_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Illustration-led onboarding walkthrough with simplified copy.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.persistenceService,
    this.nextScreen,
  });

  /// Optional override for tests.
  final OnboardingPersistenceService? persistenceService;

  /// Screen shown after onboarding completes. Defaults to [AuthGate].
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
        PageRouteBuilder(
          pageBuilder:
              (_, __, ___) => widget.nextScreen ?? const AuthGate(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 280),
        ),
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
        duration: const Duration(milliseconds: 360),
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
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child:
              _isLastPage
                  ? const SizedBox(height: 48)
                  : TextButton(
                    onPressed: _isFinishing ? null : _finish,
                    child: Text(l10n.actionSkip),
                  ),
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
                return _OnboardingPageView(page: pages[i]);
              },
            ),
          ),
          Padding(
            padding: DesignTokens.paddingPageHorizontal.add(
              EdgeInsets.only(
                top: DesignTokens.space8,
                bottom:
                    compact ? DesignTokens.space16 : DesignTokens.space24,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration:
                      disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                  child: OnboardingPageDots(
                    key: ValueKey(_index),
                    count: _pageCount,
                    currentIndex: _index,
                  ),
                ),
                const SizedBox(height: DesignTokens.space16),
                OnboardingPrimaryButton(
                  label:
                      _isLastPage ? l10n.actionGetStarted : l10n.actionNext,
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

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DesignTokens.paddingPageHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height:
                OnboardingStyle.isCompact(context)
                    ? DesignTokens.space8
                    : DesignTokens.space12,
          ),
          Expanded(
            child: Center(
              child: OnboardingIllustration(
                assetPath: page.assetPath,
                semanticsLabel: page.semanticsLabel,
                backdropVariant: page.backdropVariant,
              ),
            ),
          ),
          Text(
            page.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: OnboardingStyle.pageTitleStyle(context),
          ),
          const SizedBox(height: DesignTokens.space12),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: OnboardingStyle.pageSubtitleStyle(context),
          ),
          SizedBox(
            height:
                OnboardingStyle.isCompact(context)
                    ? DesignTokens.space12
                    : DesignTokens.space16,
          ),
        ],
      ),
    );
  }
}
