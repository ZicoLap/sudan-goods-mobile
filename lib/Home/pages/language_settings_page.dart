import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Provider.of<LocaleController>(context, listen: false);
    final current = controller.locale.value?.languageCode ?? Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _radioTile(
            context,
            title: l10n.languageEnglish,
            code: 'en',
            selectedCode: current,
            onChanged: (code) async {
              await controller.setLanguageCode(code);
            },
          ),
          const Divider(height: 1),
          _radioTile(
            context,
            title: l10n.languageArabic,
            code: 'ar',
            selectedCode: current,
            onChanged: (code) async {
              await controller.setLanguageCode(code);
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(l10n.resetOnboarding, style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.refresh_outlined),
            title: Text(l10n.resetOnboarding),
            subtitle: Text(l10n.resetOnboardingSubtitle),
            trailing: TextButton(
              onPressed: () async {
                await OnboardingPersistenceService().setHasSeenOnboarding(false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.onboardingResetSuccess)),
                  );
                }
              },
              child: Text(l10n.reset),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _radioTile(
    BuildContext context, {
    required String title,
    required String code,
    required String selectedCode,
    required ValueChanged<String> onChanged,
  }) {
    return RadioListTile<String>(
      value: code,
      groupValue: selectedCode,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      title: Text(title),
      secondary: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey.shade200,
        child: Text(code.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
