import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  static const _languages = [
    {
      'code': 'en',
      'label': 'English',
      'native': 'English',
      'flag': '🇬🇧',
      'dir': 'LTR',
    },
    {
      'code': 'ar',
      'label': 'Arabic',
      'native': 'العربية',
      'flag': '🇸🇩',
      'dir': 'RTL',
    },
  ];

  bool _isSaving = false;

  Future<void> _select(String code) async {
    final ctrl = Provider.of<LocaleController>(context, listen: false);
    if (ctrl.locale.value?.languageCode == code) return;
    setState(() => _isSaving = true);
    await ctrl.setLanguageCode(code);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = Provider.of<LocaleController>(context);
    final current =
        ctrl.locale.value?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // ── Subtitle ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.language_rounded, size: 14, color: Colors.black45),
                const SizedBox(width: 6),
                Text(
                  'SELECT LANGUAGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),

          // ── Language cards ───────────────────────────────────────────────
          ...List.generate(_languages.length, (i) {
            final lang = _languages[i];
            final code = lang['code']!;
            final isSelected = current == code;
            return Padding(
              padding: EdgeInsets.only(
                bottom: i < _languages.length - 1 ? 12 : 0,
              ),
              child: _LanguageCard(
                flag: lang['flag']!,
                label: lang['label']!,
                native: lang['native']!,
                direction: lang['dir']!,
                isSelected: isSelected,
                isSaving: _isSaving && isSelected,
                onTap: () => _select(code),
              ),
            );
          }),

          const SizedBox(height: 32),

          // ── Reset onboarding ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.settings_backup_restore_rounded,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  'ONBOARDING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.shade50,
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Colors.orange.shade700,
                ),
              ),
              title: Text(l10n.resetOnboarding, style: AppTypography.bodyBold),
              subtitle: Text(
                l10n.resetOnboardingSubtitle,
                style: AppTypography.small.copyWith(color: Colors.black45),
              ),
              trailing: TextButton(
                onPressed: () async {
                  await OnboardingPersistenceService().setHasSeenOnboarding(
                    false,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.onboardingResetSuccess),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  l10n.reset,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String label;
  final String native;
  final String direction;
  final bool isSelected;
  final bool isSaving;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.label,
    required this.native,
    required this.direction,
    required this.isSelected,
    required this.isSaving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 16 : 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        native,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              direction,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSaving)
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.black26,
                        width: 2,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                            : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
