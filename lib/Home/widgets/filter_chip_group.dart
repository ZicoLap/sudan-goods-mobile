import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';

/// A small selectable chip with an optional leading icon.
class FilterChipData {
  final String key;
  final String label;
  final IconData? icon;

  const FilterChipData({required this.key, required this.label, this.icon});
}

/// Generic group of selectable filter chips.
class FilterChipGroup extends StatelessWidget {
  final List<FilterChipData> chips;
  final Set<String> selectedKeys;
  final ValueChanged<String> onSelected;

  const FilterChipGroup({
    super.key,
    required this.chips,
    required this.selectedKeys,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          chips.map((chip) {
            final selected = selectedKeys.contains(chip.key);
            return GestureDetector(
              onTap: () => onSelected(chip.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        selected
                            ? AppColors.primary
                            : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chip.icon != null) ...[
                      Icon(
                        chip.icon,
                        size: 14,
                        color: selected ? Colors.white : Colors.black45,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      chip.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
