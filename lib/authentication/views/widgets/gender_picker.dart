import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';

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
    return Row(
      children: [
        const Text("Gender:", style: TextStyle(fontWeight: FontWeight.bold)),
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
          items: const [
            DropdownMenuItem(value: "male", child: Text("Male")),
            DropdownMenuItem(value: "female", child: Text("Female")),
          ],
        ),
      ],
    );
  }
}
