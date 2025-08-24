import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/onboarding/onboarding_persistence_service.dart';
import 'package:sudan_goods/authentication/auth_gate_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 7) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingPersistenceService().setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.onbTitle1,
      l10n.onbTitle2,
      l10n.onbTitle3,
      l10n.onbTitle4,
      l10n.onbTitle5,
      l10n.onbTitle6,
      l10n.onbTitle7,
      l10n.onbTitle8,
    ];
    final bodies = [
      l10n.onbBody1,
      l10n.onbBody2,
      l10n.onbBody3,
      l10n.onbBody4,
      l10n.onbBody5,
      l10n.onbBody6,
      l10n.onbBody7,
      l10n.onbBody8,
    ];
    final icons = [
      Icons.local_mall_rounded,
      Icons.search_rounded,
      Icons.storefront_rounded,
      Icons.shopping_cart_rounded,
      Icons.payments_rounded,
      Icons.local_shipping_rounded,
      Icons.support_agent_rounded,
      Icons.verified_rounded,
    ];

    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: 8,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: DesignTokens.paddingPageHorizontal.add(
                        const EdgeInsets.only(top: DesignTokens.space32),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                              border: Border.all(color: Colors.black.withOpacity(0.06)),
                              boxShadow: DesignTokens.shadowSmall,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.space20,
                              vertical: DesignTokens.space24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _iconBubble(icons[i]),
                                const SizedBox(height: DesignTokens.space20),
                                Text(
                                  titles[i],
                                  style: AppTypography.heading4,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: DesignTokens.space12),
                                Text(
                                  bodies[i],
                                  style: AppTypography.bodyLarge.copyWith(color: AppColors.text),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                    boxShadow: DesignTokens.shadowSmall,
                  ),
                  padding: const EdgeInsets.all(DesignTokens.space12),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _finish,
                        child: Text(l10n.actionSkip),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            child: _Dots(count: 8, index: _index),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _next,
                          child: Text(
                            _index == 7 ? l10n.actionGetStarted : l10n.actionNext,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 8,
          width: active ? 18 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: active ? null : Border.all(color: Colors.black.withOpacity(0.10)),
            color: active ? null : Colors.black.withOpacity(0.08),
            gradient: active
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.95),
                      AppColors.primary.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
        );
      }),
    );
  }
}

Widget _iconBubble(IconData icon) {
  return Container(
    width: 72,
    height: 72,
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
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: 36),
  );
}
