import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

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
    return Row(
      children: [
        Text(l10n.genderLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: gender,
          icon: const Icon(Icons.arrow_drop_down),
          underline: Container(height: 2, color: AppColors.primary),
          style: const TextStyle(color: AppColors.text),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: AppColors.inputField,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          items: [
            DropdownMenuItem(value: "male", child: Text(l10n.male)),
            DropdownMenuItem(value: "female", child: Text(l10n.female)),
          ],
        ),
      ],
    );
  }
}
