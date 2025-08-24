import 'package:flutter/material.dart';
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
    final materialL10n = MaterialLocalizations.of(context);
    final textController = TextEditingController(
      text: materialL10n.formatFullDate(birthday),
    );
    return TextFormField(
      readOnly: true,
      controller: textController,
      decoration: InputDecoration(
        labelText: l10n.birthdayLabel,
        prefixIcon: const Icon(Icons.cake_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_rounded),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: birthday,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onPicked(picked);
            }
          },
        ),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: birthday,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
    );
  }
}
