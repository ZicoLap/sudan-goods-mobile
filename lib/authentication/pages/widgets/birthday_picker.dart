import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

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
    return TextFormField(
      readOnly: true,
      controller: _controller,
      decoration: InputDecoration(
        labelText: l10n.birthdayLabel,
        prefixIcon: const Icon(Icons.cake_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_rounded),
          onPressed: _pickDate,
        ),
      ),
      onTap: _pickDate,
      validator: (_) {
        final age = DateTime.now().difference(widget.birthday).inDays ~/ 365;
        if (age < 13) return l10n.birthdayAgeError;
        return null;
      },
    );
  }
}
