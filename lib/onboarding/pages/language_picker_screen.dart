import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/onboarding/pages/onboarding_screen.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// First-run language selection with staggered entry animation.
class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCode;
  bool _isContinuing = false;
  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preselectDeviceLanguage();
      if (!MediaQuery.disableAnimationsOf(context)) {
        _entryController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _preselectDeviceLanguage() {
    final deviceCode = Localizations.localeOf(context).languageCode;
    if (deviceCode == 'en' || deviceCode == 'ar') {
      setState(() => _selectedCode = deviceCode);
    }
  }

  void _selectLanguage(String code) {
    if (_isContinuing) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedCode = code);
  }

  Future<void> _continue() async {
    final code = _selectedCode;
    if (code == null || _isContinuing) return;

    setState(() => _isContinuing = true);
    HapticFeedback.lightImpact();

    try {
      final controller = Provider.of<LocaleController>(context, listen: false);
      await controller.setLanguageCode(code);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        onboardingFadeRoute(const OnboardingScreen()),
      );
    } finally {
      if (mounted) setState(() => _isContinuing = false);
    }
  }

  Animation<double> _stagger(int index, {int total = 3}) {
    final start = (index / total) * 0.40;
    final end = (start + 0.60).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entryController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  /// Returns localizations for the currently selected language so the UI
  /// reflects the chosen language before the user taps Continue.
  AppLocalizations _l10nFor(BuildContext context) {
    final code = _selectedCode;
    if (code == null) return AppLocalizations.of(context) ?? lookupAppLocalizations(const Locale('en'));
    return lookupAppLocalizations(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final compact = OnboardingStyle.isCompact(context);
    final l10n = AppLocalizations.of(context);           // device locale (for illustration label)
    final selectedL10n = _l10nFor(context);              // selected language (for UI text)

    return OnboardingShell(
      bottomBar: Padding(
        padding: DesignTokens.paddingPageHorizontal.add(
          EdgeInsets.only(
            bottom: compact ? DesignTokens.space16 : DesignTokens.space24,
          ),
        ),
        child: OnboardingPrimaryButton(
          label: selectedL10n.actionContinue,
          onPressed: _selectedCode == null ? null : _continue,
          isLoading: _isContinuing,
          showTrailingIcon: true,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: compact ? DesignTokens.space10 : DesignTokens.space16),

          // ── Illustration ─────────────────────────────────────────
          Expanded(
            flex: compact ? 5 : 6,
            child: _FadeSlideIn(
              animation: _stagger(0),
              slideOffset: 20,
              child: Center(
                child: OnboardingIllustration(
                  assetPath: OnboardingAssets.languageWelcome,
                  semanticsLabel:
                      l10n?.onbIllustrationLanguage ?? 'Welcome illustration',
                  maxHeight: OnboardingStyle.illustrationMaxHeight(context),
                  enableFloat: true,
                ),
              ),
            ),
          ),

          // ── Heading ──────────────────────────────────────────────
          _FadeSlideIn(
            animation: _stagger(1),
            child: Padding(
              padding: DesignTokens.paddingPageHorizontal,
              child: _LanguagePickerHeader(l10n: selectedL10n),
            ),
          ),

          SizedBox(height: compact ? DesignTokens.space16 : DesignTokens.space20),

          // ── Language cards ────────────────────────────────────────
          _FadeSlideIn(
            animation: _stagger(2),
            child: Padding(
              padding: DesignTokens.paddingPageHorizontal,
              child: Column(
                children: [
                  _LanguageTileRow(
                    code: 'en',
                    isSelected: _selectedCode == 'en',
                    isDisabled: _isContinuing,
                    uiL10n: selectedL10n,
                    onTap: () => _selectLanguage('en'),
                  ),
                  const SizedBox(height: DesignTokens.space12),
                  _LanguageTileRow(
                    code: 'ar',
                    isSelected: _selectedCode == 'ar',
                    isDisabled: _isContinuing,
                    uiL10n: selectedL10n,
                    onTap: () => _selectLanguage('ar'),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: compact ? DesignTokens.space12 : DesignTokens.space16),
        ],
      ),
    );
  }
}

/// Lightweight fade + upward-slide entry for staggered content.
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.animation,
    required this.child,
    this.slideOffset = 28.0,
  });

  final Animation<double> animation;
  final Widget child;
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, inner) => Transform.translate(
          offset: Offset(0, slideOffset * (1 - animation.value)),
          child: inner,
        ),
        child: child,
      ),
    );
  }
}

class _LanguagePickerHeader extends StatelessWidget {
  const _LanguagePickerHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final compact = OnboardingStyle.isCompact(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Sudan Goods',
          textAlign: TextAlign.center,
          style: OnboardingStyle.languagePickerTitleStyle(context),
        ),
        SizedBox(height: compact ? DesignTokens.space8 : DesignTokens.space10),
        const Center(child: OnboardingAccentLine()),
        SizedBox(height: compact ? DesignTokens.space8 : DesignTokens.space10),
        Text(
          l10n.languagePickerSectionTitle,
          textAlign: TextAlign.center,
          style: OnboardingStyle.languagePickerSubtitleStyle(context),
        ),
      ],
    );
  }
}

class _LanguageTileRow extends StatelessWidget {
  const _LanguageTileRow({
    required this.code,
    required this.isSelected,
    required this.onTap,
    required this.isDisabled,
    required this.uiL10n,
  });

  final String code;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDisabled;
  final AppLocalizations uiL10n;

  static const String _englishNative = 'English';
  static const String _arabicNative = 'العربية';

  String? _secondaryLabel(String nativeLabel) {
    final translated =
        code == 'ar' ? uiL10n.langArabic : uiL10n.langEnglish;
    if (nativeLabel.trim().toLowerCase() == translated.trim().toLowerCase()) {
      return null;
    }
    return translated;
  }

  @override
  Widget build(BuildContext context) {
    final nativeLabel = code == 'ar' ? _arabicNative : _englishNative;

    return OnboardingLanguageTile(
      code: code,
      nativeLabel: nativeLabel,
      secondaryLabel: _secondaryLabel(nativeLabel),
      isSelected: isSelected,
      isDisabled: isDisabled,
      onTap: onTap,
    );
  }
}
