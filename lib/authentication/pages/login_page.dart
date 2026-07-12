import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/data/login_form_data.dart';
import 'package:sudan_goods/authentication/pages/widgets/login_form.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formData = LoginFormData();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    AppColors.primary.withValues(alpha: 0.03),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.35, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: DesignTokens.paddingPageHorizontal.add(
                const EdgeInsets.only(
                  top: DesignTokens.space48,
                  bottom: DesignTokens.space32,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _iconBubble(Icons.storefront_rounded),
                      const SizedBox(height: DesignTokens.space20),
                      Text(
                        l10n.appTitle,
                        style: AppTypography.heading5.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      Text(
                        'Welcome back',
                        style: AppTypography.heading4.copyWith(
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      Text(
                        'Sign in to continue shopping',
                        style: AppTypography.body.copyWith(
                          color: Colors.black45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.space32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXLarge,
                          ),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(DesignTokens.space24),
                        child: LoginForm(formData: _formData),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _iconBubble(IconData icon) {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [AppColors.primary, Color(0xFFFF8C3A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: 38),
  );
}
