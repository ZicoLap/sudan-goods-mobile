
// ✅ lib/domains/customer/checkout/sections/checkout_note_section.dart
import 'package:flutter/material.dart';

class CheckoutNoteSection extends StatefulWidget {
  final TextEditingController controller;

  const CheckoutNoteSection({super.key, required this.controller});

  @override
  State<CheckoutNoteSection> createState() => _CheckoutNoteSectionState();
}


class _CheckoutNoteSectionState extends State<CheckoutNoteSection> {
  String note = "Add delivery notes";

void _editNote() async {
  final updated = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _NoteBottomSheet(initialValue: widget.controller.text),
  );
  if (updated != null && updated.trim().isNotEmpty) {
    setState(() {
      widget.controller.text = updated.trim();
      note = widget.controller.text;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _editNote,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_note, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(note, style: const TextStyle(fontSize: 16)),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _NoteBottomSheet extends StatefulWidget {
  final String initialValue;

  const _NoteBottomSheet({required this.initialValue});

  @override
  State<_NoteBottomSheet> createState() => _NoteBottomSheetState();
}


class _NoteBottomSheetState extends State<_NoteBottomSheet> {

  late final TextEditingController _controller;

@override
void initState() {
  super.initState();
  _controller = TextEditingController(text: widget.initialValue);
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Add a note to this order", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "e.g. Please ring the bell or leave at the door",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text("Save Note"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
