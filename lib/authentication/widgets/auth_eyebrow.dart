import 'package:flutter/material.dart';
import 'package:sudan_goods/onboarding/onboarding_style.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Eyebrow pill label — icon + uppercase category tag.
class AuthEyebrow extends StatelessWidget {
  final IconData icon;
  final String label;

  const AuthEyebrow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space12,
        vertical: DesignTokens.space6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: DesignTokens.space6),
          Text(
            label,
            style: OnboardingStyle.pageEyebrowStyle(context).copyWith(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
