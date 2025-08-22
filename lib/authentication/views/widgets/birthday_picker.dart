import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class BirthdayPicker extends StatelessWidget {
  final DateTime birthday;
  final ValueChanged<DateTime> onPicked;

  const BirthdayPicker({
    super.key,
    required this.birthday,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(l10n.birthdayLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: birthday,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: AppColors.primary,
                    colorScheme: ThemeData.light().colorScheme.copyWith(
                      primary: AppColors.primary,
                    ),
                    dialogTheme: DialogTheme(
                      backgroundColor: AppColors.inputField,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onPicked(picked);
            }
          },
          child: Text("${birthday.toLocal()}".split(' ')[0]),
        ),
      ],
    );
  }
}
