
// ✅ lib/domains/customer/checkout/sections/checkout_note_section.dart
import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class CheckoutNoteSection extends StatefulWidget {
  final TextEditingController controller;

  const CheckoutNoteSection({super.key, required this.controller});

  @override
  State<CheckoutNoteSection> createState() => _CheckoutNoteSectionState();
}


class _CheckoutNoteSectionState extends State<CheckoutNoteSection> {

void _editNote() async {
  final updated = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _NoteBottomSheet(initialValue: widget.controller.text),
  );
  if (updated != null && updated.trim().isNotEmpty) {
    setState(() {
      widget.controller.text = updated.trim();
    });
  }
}

  Widget _iconBubble(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.95),
            AppColors.primary.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final displayText = widget.controller.text.trim().isNotEmpty
        ? widget.controller.text.trim()
        : AppLocalizations.of(context)!.addDeliveryNotes;
    return GestureDetector(
      onTap: _editNote,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.space12),
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: DesignTokens.shadowSmall,
        ),
        child: Row(
          children: [
            _iconBubble(Icons.edit_note),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: Text(
                displayText,
                style: AppTypography.bodyLarge,
              ),
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
          Text(AppLocalizations.of(context)!.addNoteTitle, style: AppTypography.heading6),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.addNoteHint,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: Text(AppLocalizations.of(context)!.saveNote),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
