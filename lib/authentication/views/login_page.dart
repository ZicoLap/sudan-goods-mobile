import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/data/login_form_data.dart';
import 'package:sudan_goods/authentication/views/widgets/login_form.dart';
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
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.06),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: DesignTokens.paddingPageHorizontal.add(
              const EdgeInsets.symmetric(vertical: DesignTokens.space32),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBubble(Icons.lock_rounded),
                    const SizedBox(height: DesignTokens.space16),
                    Text(
                      'Welcome back',
                      style: AppTypography.heading4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.space24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                        boxShadow: DesignTokens.shadowSmall,
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
      ),
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
