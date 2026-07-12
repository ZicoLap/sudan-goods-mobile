import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class GenderPicker extends StatelessWidget {
  final String gender;
  final ValueChanged<String> onChanged;

  const GenderPicker({
    super.key,
    required this.gender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMale = gender == 'male';

    const trackRadius = BorderRadius.all(
      Radius.circular(DesignTokens.radiusLarge),
    );
    const double thumbPadding = 4.0;
    const Color trackColor = Color(0xFFFFF3E8);
    const Color borderColor = Color(0x1FF36805);
    const Color selectedFg = Colors.white;
    final Color unselectedFg = Colors.black.withValues(alpha: 0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: DesignTokens.space8),
          child: Text(
            l10n.genderLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final thumbWidth = (constraints.maxWidth - thumbPadding * 2) / 2;
            return SizedBox(
              height: 52,
              child: Material(
                color: trackColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: trackRadius,
                  side: BorderSide(color: borderColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(thumbPadding),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        alignment:
                            isMale
                                ? AlignmentDirectional.centerStart
                                : AlignmentDirectional.centerEnd,
                        child: Container(
                          width: thumbWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.82),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: trackRadius,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.30,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: trackRadius,
                            onTap: () => onChanged('male'),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.male_rounded,
                                    size: 20,
                                    color: isMale ? selectedFg : unselectedFg,
                                  ),
                                  const SizedBox(width: DesignTokens.space8),
                                  Text(
                                    l10n.male,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isMale ? selectedFg : unselectedFg,
                                      fontWeight:
                                          isMale
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: trackRadius,
                            onTap: () => onChanged('female'),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.female_rounded,
                                    size: 20,
                                    color: !isMale ? selectedFg : unselectedFg,
                                  ),
                                  const SizedBox(width: DesignTokens.space8),
                                  Text(
                                    l10n.female,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          !isMale ? selectedFg : unselectedFg,
                                      fontWeight:
                                          !isMale
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
