import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class BirthdayPicker extends StatefulWidget {
  final DateTime birthday;
  final ValueChanged<DateTime> onPicked;

  const BirthdayPicker({
    super.key,
    required this.birthday,
    required this.onPicked,
  });

  @override
  State<BirthdayPicker> createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State<BirthdayPicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncText();
  }

  @override
  void didUpdateWidget(BirthdayPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.birthday != widget.birthday) {
      _syncText();
    }
  }

  void _syncText() {
    final formatted = MaterialLocalizations.of(
      context,
    ).formatFullDate(widget.birthday);
    if (_controller.text != formatted) {
      _controller.text = formatted;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      widget.onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              l10n.birthdayLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.space8),
        SizedBox(
          height: 52,
          child: TextFormField(
            readOnly: true,
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.cake_rounded, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                onPressed: _pickDate,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
            ),
            onTap: _pickDate,
            validator: (_) {
              final today = DateTime.now();
              final birthDate = widget.birthday;
              var age = today.year - birthDate.year;
              final monthDiff = today.month - birthDate.month;
              if (monthDiff < 0 ||
                  (monthDiff == 0 && today.day < birthDate.day)) {
                age--;
              }
              if (age < 13) return l10n.birthdayAgeError;
              return null;
            },
          ),
        ),
      ],
    );
  }
}
