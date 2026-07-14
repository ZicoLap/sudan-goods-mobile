import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_persistence_service.dart';
import 'package:sudan_goods/l10n/supported_app_locales.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/onboarding/pages/language_picker_screen.dart';
import 'package:sudan_goods/onboarding/pages/onboarding_screen.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/authentication/gate/auth_gate.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Resolves first-run routing: language picker → onboarding → auth.
class AppStartGate extends StatefulWidget {
  AppStartGate({
    super.key,
    LocalePersistenceService? localePersistence,
    OnboardingPersistenceService? onboardingPersistence,
    this.postOnboardingScreen,
  }) : _localePersistence = localePersistence ?? LocalePersistenceService(),
       _onboardingPersistence =
           onboardingPersistence ?? OnboardingPersistenceService();

  final LocalePersistenceService _localePersistence;
  final OnboardingPersistenceService _onboardingPersistence;

  /// Optional override used in tests instead of [AuthGate].
  final Widget? postOnboardingScreen;

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  late Future<_StartState> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<_StartState> _load() async {
    final savedCode = await widget._localePersistence.getSavedLanguageCode();
    final hasSeen = await widget._onboardingPersistence.getHasSeenOnboarding();
    return _StartState(
      languageCode:
          SupportedAppLocales.isSupported(savedCode) ? savedCode : null,
      hasSeenOnboarding: hasSeen,
    );
  }

  void _retry() {
    setState(() {
      _loadFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartState>(
      future: _loadFuture,
      builder: (context, snap) {
        if (snap.hasError) {
          return _StartGateError(onRetry: _retry);
        }
        if (!snap.hasData) {
          return const OnboardingLoadingView();
        }
        final state = snap.data!;
        if (!SupportedAppLocales.isSupported(state.languageCode)) {
          return const LanguagePickerScreen();
        }
        if (!state.hasSeenOnboarding) {
          return const OnboardingScreen();
        }
        return widget.postOnboardingScreen ?? const AuthGate();
      },
    );
  }
}

class _StartState {
  final String? languageCode;
  final bool hasSeenOnboarding;

  const _StartState({required this.languageCode, required this.hasSeenOnboarding});
}

class _StartGateError extends StatelessWidget {
  const _StartGateError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return OnboardingShell(
      body: Center(
        child: Padding(
          padding: DesignTokens.paddingPageHorizontal.add(
            const EdgeInsets.symmetric(vertical: DesignTokens.space24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(
                l10n?.appStartLoadError ??
                    'Unable to load app settings. Please try again.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.text.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: DesignTokens.space24),
              OnboardingPrimaryButton(
                label: l10n?.retry ?? 'Retry',
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
