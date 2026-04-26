import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/onboarding/onboarding_screen.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

/// Modernized language picker with static bilingual display,
/// improved visual hierarchy, and polished selection cards.
class LanguagePickerScreen extends StatelessWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*   appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(begin: const Offset(0, 0.30), end: Offset.zero).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: Text(
            headerTitle,
            key: ValueKey(headerTitle),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        centerTitle: true,
      ), */
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withAlpha(18), // 7% opacity
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: DesignTokens.paddingPageHorizontal,
            child: Column(
              children: [
                const Spacer(flex: 2),
                // App branding icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFF8A3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(77),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: DesignTokens.space24),
                // Static bilingual welcome text
                Text(
                  'Sudan Goods',
                  style: AppTypography.heading2.copyWith(
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                Text(
                  'Welcome to the biggest Sudanese\nonline shopping hub',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                Text(
                  'مرحبا بيك في اكبر مركز تسوق الكتروني سوداني',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: Colors.black38,
                    height: 1.4,
                  ),
                ),
                const Spacer(flex: 3),
                // Language selection cards
                _LanguageCard(code: 'en'),
                const SizedBox(height: DesignTokens.space16),
                _LanguageCard(code: 'ar'),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Language selection card with modern styling
class _LanguageCard extends StatelessWidget {
  final String code;

  const _LanguageCard({required this.code});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LocaleController>(context, listen: false);
    final isArabic = code == 'ar';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await controller.setLanguageCode(code);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            border: Border.all(color: Colors.black.withAlpha(15), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space20,
            vertical: DesignTokens.space16,
          ),
          child: Localizations.override(
            context: context,
            locale: Locale(code),
            child: Builder(
              builder: (ctx) {
                final l10n = AppLocalizations.of(ctx);
                return Row(
                  children: [
                    // Language flag/icon bubble
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF8A3D)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(51),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isArabic ? 'ع' : 'EN',
                          style: AppTypography.bodyBold.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? (l10n?.languageArabic ?? 'العربية')
                                : (l10n?.languageEnglish ?? 'English'),
                            style: AppTypography.heading6.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space4),
                          Text(
                            isArabic ? 'Arabic' : 'English',
                            style: AppTypography.small.copyWith(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isArabic ? Icons.chevron_left : Icons.chevron_right,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
