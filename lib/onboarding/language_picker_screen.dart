import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/onboarding/onboarding_screen.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  late final Timer _toggleTimer;
  bool _showArabic = false;

  @override
  void initState() {
    super.initState();
    _toggleTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _showArabic = !_showArabic);
    });
  }

  @override
  void dispose() {
    _toggleTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using AppLocalizations within localized Builders below; no top-level reference needed here.
    const String titleEn = 'Welcome to the biggest Sudanese online shopping hub';
    const String titleAr = 'مرحبا بيك في اكبر مركز تسوق الكتروني سوداني';
    final String headerTitle = _showArabic ? titleAr : titleEn;
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
              AppColors.primary.withOpacity(0.05),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.space20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: DesignTokens.paddingPageHorizontal,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.95),
                                  AppColors.primary.withOpacity(0.75),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                              ],
                            ),
                            child: const Icon(Icons.language, size: 18, color: Colors.white),
                          ),
                          const SizedBox(height: DesignTokens.space8),
                          SizedBox(
                            height: 64,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                final offset = Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(position: offset, child: child),
                                );
                              },
                              child: Text(
                                headerTitle,
                                key: ValueKey(headerTitle),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sectionTitle.copyWith(height: 1.2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space24),
                      _languageCard(context, code: 'en'),
                      const SizedBox(height: DesignTokens.space12),
                      _languageCard(context, code: 'ar'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _languageCard(BuildContext context, {required String code}) {
    final controller = Provider.of<LocaleController>(context, listen: false);

    return InkWell(
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: DesignTokens.shadowSmall,
        ),
        padding: const EdgeInsets.all(DesignTokens.space12),
        child: Localizations.override(
          context: context,
          locale: Locale(code),
          child: Builder(
            builder: (ctx) {
              final l10n = AppLocalizations.of(ctx);
              final isRtl = code == 'ar';
              return Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.95),
                            AppColors.primary.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.language, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            code == 'ar'
                                ? (l10n?.languageArabic ?? 'Arabic')
                                : (l10n?.languageEnglish ?? 'English'),
                            style: AppTypography.cardTitle,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n?.onbTitle1 ?? 'Welcome to Sudan Goods',
                            style: AppTypography.small.copyWith(color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n?.onbBody1 ??
                                'Bringing Sudanese products closer to you.',
                            style: AppTypography.small.copyWith(color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.95),
                            AppColors.primary.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Icon(isRtl ? Icons.chevron_left : Icons.chevron_right, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
