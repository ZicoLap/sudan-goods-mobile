import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/onboarding/onboarding_screen.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// First-run language selection with premium illustration hero.
class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  String? _selectedCode;
  bool _isContinuing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _preselectDeviceLanguage());
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

  @override
  Widget build(BuildContext context) {
    final compact = OnboardingStyle.isCompact(context);
    final l10n = AppLocalizations.of(context);

    return OnboardingShell(
      bottomBar: Padding(
        padding: DesignTokens.paddingPageHorizontal.add(
          EdgeInsets.only(
            bottom: compact ? DesignTokens.space16 : DesignTokens.space24,
          ),
        ),
        child: OnboardingPrimaryButton(
          label: l10n?.actionContinue ?? 'Continue',
          onPressed: _selectedCode == null ? null : _continue,
          isLoading: _isContinuing,
          showTrailingIcon: true,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: DesignTokens.paddingPageHorizontal.add(
              EdgeInsets.only(
                top: compact ? DesignTokens.space8 : DesignTokens.space12,
              ),
            ),
            child: const Center(child: OnboardingBrandMark()),
          ),
          Expanded(
            flex: compact ? 5 : 6,
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
          Padding(
            padding: DesignTokens.paddingPageHorizontal,
            child: _LanguagePickerHeader(),
          ),
          SizedBox(height: compact ? DesignTokens.space20 : DesignTokens.space24),
          Padding(
            padding: DesignTokens.paddingPageHorizontal,
            child: _LanguageTileRow(
              code: 'en',
              isSelected: _selectedCode == 'en',
              isDisabled: _isContinuing,
              onTap: () => _selectLanguage('en'),
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          Padding(
            padding: DesignTokens.paddingPageHorizontal,
            child: _LanguageTileRow(
              code: 'ar',
              isSelected: _selectedCode == 'ar',
              isDisabled: _isContinuing,
              onTap: () => _selectLanguage('ar'),
            ),
          ),
          SizedBox(height: compact ? DesignTokens.space16 : DesignTokens.space20),
        ],
      ),
    );
  }
}

class _LanguagePickerHeader extends StatelessWidget {
  const _LanguagePickerHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n?.appTitle ?? 'Sudan Goods',
          textAlign: TextAlign.center,
          style: OnboardingStyle.languagePickerTitleStyle(context),
        ),
        const SizedBox(height: DesignTokens.space12),
        const Center(child: OnboardingAccentLine()),
        const SizedBox(height: DesignTokens.space12),
        Text(
          l10n?.languagePickerSectionTitle ??
              l10n?.selectLanguage ??
              'Choose your language',
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
  });

  final String code;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDisabled;

  static const String _englishNative = 'English';
  static const String _arabicNative = 'العربية';

  String? _secondaryLabel(AppLocalizations? uiL10n, String nativeLabel) {
    final translated =
        code == 'ar'
            ? (uiL10n?.langArabic ?? 'Arabic')
            : (uiL10n?.langEnglish ?? 'English');
    if (nativeLabel.trim().toLowerCase() == translated.trim().toLowerCase()) {
      return null;
    }
    return translated;
  }

  @override
  Widget build(BuildContext context) {
    final uiL10n = AppLocalizations.of(context);
    final nativeLabel = code == 'ar' ? _arabicNative : _englishNative;

    return OnboardingLanguageTile(
      code: code,
      nativeLabel: nativeLabel,
      secondaryLabel: _secondaryLabel(uiL10n, nativeLabel),
      isSelected: isSelected,
      isDisabled: isDisabled,
      onTap: onTap,
    );
  }
}
