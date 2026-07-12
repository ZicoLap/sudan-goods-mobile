import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/onboarding/onboarding_assets.dart';
import 'package:sudan_goods/onboarding/onboarding_screen.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// First-run language selection with illustration hero.
class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  String? _loadingCode;

  Future<void> _selectLanguage(String code) async {
    if (_loadingCode != null) return;

    setState(() => _loadingCode = code);
    HapticFeedback.lightImpact();

    try {
      final controller = Provider.of<LocaleController>(context, listen: false);
      await controller.setLanguageCode(code);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 280),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingCode = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final compact = OnboardingStyle.isCompact(context);
    final titleStyle =
        compact
            ? AppTypography.heading4.copyWith(
              color: AppColors.text,
              letterSpacing: -0.4,
            )
            : AppTypography.heading2.copyWith(
              color: AppColors.text,
              letterSpacing: -0.5,
            );

    return OnboardingShell(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: DesignTokens.paddingPageHorizontal.add(
              EdgeInsets.only(
                top: compact ? DesignTokens.space8 : DesignTokens.space16,
                bottom: DesignTokens.space24,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height:
                          compact
                              ? DesignTokens.space4
                              : DesignTokens.space8,
                    ),
                    OnboardingIllustration(
                      assetPath: OnboardingAssets.languageWelcome,
                      semanticsLabel:
                          l10n?.onbIllustrationLanguage ??
                          'Welcome illustration',
                      maxHeight: OnboardingStyle.illustrationMaxHeight(context) * 0.85,
                    ),
                    SizedBox(
                      height:
                          compact
                              ? DesignTokens.space12
                              : DesignTokens.space20,
                    ),
                    Text(
                      l10n?.appTitle ?? 'Sudan Goods',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    Text(
                      l10n?.languagePickerSectionTitle ??
                          l10n?.selectLanguage ??
                          'Choose your language',
                      textAlign: TextAlign.center,
                      style: OnboardingStyle.pageSubtitleStyle(context),
                    ),
                    SizedBox(
                      height:
                          compact
                              ? DesignTokens.space20
                              : DesignTokens.space24,
                    ),
                    _LanguageCard(
                      code: 'en',
                      isLoading: _loadingCode == 'en',
                      isDisabled: _loadingCode != null && _loadingCode != 'en',
                      onTap: () => _selectLanguage('en'),
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    _LanguageCard(
                      code: 'ar',
                      isLoading: _loadingCode == 'ar',
                      isDisabled: _loadingCode != null && _loadingCode != 'ar',
                      onTap: () => _selectLanguage('ar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.code,
    required this.onTap,
    required this.isLoading,
    required this.isDisabled,
  });

  final String code;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final isArabic = code == 'ar';

    return Localizations.override(
      context: context,
      locale: Locale(code),
      child: Builder(
        builder: (ctx) {
          final l10n = AppLocalizations.of(ctx);
          final nativeLabel =
              isArabic
                  ? (l10n?.languageArabic ?? 'العربية')
                  : (l10n?.languageEnglish ?? 'English');
          final secondaryLabel =
              isArabic
                  ? (l10n?.langArabic ?? 'Arabic')
                  : (l10n?.langEnglish ?? 'English');

          return Semantics(
            button: true,
            enabled: !isDisabled,
            label: nativeLabel,
            child: Material(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                side: BorderSide(
                  color: AppColors.text.withValues(alpha: 0.08),
                ),
              ),
              child: InkWell(
                onTap: isDisabled ? null : onTap,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space16,
                      vertical: DesignTokens.space12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: OnboardingStyle.brandGradient,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isArabic ? 'ع' : 'EN',
                            style: AppTypography.bodyBold.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                nativeLabel,
                                style: AppTypography.heading6.copyWith(
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: DesignTokens.space4),
                              Text(
                                secondaryLabel,
                                style: AppTypography.small.copyWith(
                                  color: AppColors.text.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isLoading)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        else
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                            textDirection:
                                isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
