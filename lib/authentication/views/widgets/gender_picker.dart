import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
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
    final scheme = Theme.of(context).colorScheme;

    return InputDecorator(
      decoration: const InputDecoration(
        // Keep label for consistency with text fields; remove border chrome.
        labelText: null,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ).copyWith(labelText: l10n.genderLabel),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackRadius = BorderRadius.circular(DesignTokens.radiusLarge);
          const double thumbPadding = 4.0;
          final thumbWidth = (constraints.maxWidth - (thumbPadding * 2)) / 2;
          final isMale = gender == 'male';

          final Color trackColor = scheme.surfaceContainerHighest.withOpacity(0.14);
          final Color borderColor = scheme.outline.withOpacity(0.35);
          final Color thumbColor = scheme.primaryContainer;
          final Color selectedFg = scheme.onPrimaryContainer;
          final Color unselectedFg = scheme.onSurfaceVariant;

          return SizedBox(
            height: 56,
            child: Material(
              color: trackColor,
              shape: RoundedRectangleBorder(
                borderRadius: trackRadius,
                side: BorderSide(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Sliding thumb
                  Padding(
                    padding: const EdgeInsets.all(thumbPadding),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      alignment: isMale
                          ? AlignmentDirectional.centerStart
                          : AlignmentDirectional.centerEnd,
                      child: Container(
                        width: thumbWidth,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          borderRadius: trackRadius,
                          boxShadow: DesignTokens.shadowSmall,
                        ),
                      ),
                    ),
                  ),

                  // Options layer
                  Row(
                    children: [
                      // Male
                      Expanded(
                        child: InkWell(
                          borderRadius: trackRadius,
                          onTap: () => onChanged('male'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.male_rounded, size: 20, color: isMale ? selectedFg : unselectedFg),
                              const SizedBox(width: DesignTokens.space8),
                              Flexible(
                                child: Text(
                                  l10n.male,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isMale ? selectedFg : unselectedFg,
                                    fontWeight: isMale ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Female
                      Expanded(
                        child: InkWell(
                          borderRadius: trackRadius,
                          onTap: () => onChanged('female'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.female_rounded, size: 20, color: !isMale ? selectedFg : unselectedFg),
                              const SizedBox(width: DesignTokens.space8),
                              Flexible(
                                child: Text(
                                  l10n.female,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: !isMale ? selectedFg : unselectedFg,
                                    fontWeight: !isMale ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}
