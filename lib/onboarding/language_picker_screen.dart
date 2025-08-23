import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/onboarding/onboarding_screen.dart';

class LanguagePickerScreen extends StatelessWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.selectLanguage ?? 'Select language'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _languageCard(context, code: 'en'),
            const SizedBox(height: 16),
            _languageCard(context, code: 'ar'),
          ],
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        code.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            code == 'ar'
                                ? (l10n?.languageArabic ?? 'Arabic')
                                : (l10n?.languageEnglish ?? 'English'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n?.onbTitle1 ?? 'Welcome to Sudan Goods',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n?.onbBody1 ??
                                'Bringing Sudanese products closer to you.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
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
