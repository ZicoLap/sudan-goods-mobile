
// ✅ lib/domains/customer/checkout/sheets/edit_user_info_sheet.dart
import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class EditUserInfoSheet extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;

  const EditUserInfoSheet({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  @override
  State<EditUserInfoSheet> createState() => _EditUserInfoSheetState();
}

class _EditUserInfoSheetState extends State<EditUserInfoSheet> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'phone': phoneController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
        child: Center(child: Icon(icon, color: Colors.white, size: 20)),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + DesignTokens.space16,
          left: DesignTokens.space20,
          right: DesignTokens.space20,
          top: DesignTokens.space12,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),

              // Header
              Row(
                children: [
                  _iconBubble(Icons.person_outline),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: Text(
                      l10n.editProfile,
                      style: AppTypography.heading6,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),

              const SizedBox(height: DesignTokens.space16),

              // Form fields
              TextField(
                controller: firstNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.firstName),
              ),
              const SizedBox(height: DesignTokens.space12),
              TextField(
                controller: lastNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.lastName),
              ),
              const SizedBox(height: DesignTokens.space12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: l10n.phone),
              ),

              const SizedBox(height: DesignTokens.space20),

              // Primary action - gradient button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: InkWell(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  onTap: _submit,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.98),
                          AppColors.primary.withOpacity(0.82),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: DesignTokens.shadowSmall,
                    ),
                    child: Center(
                      child: Text(
                        l10n.saveChanges,
                        style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: DesignTokens.space12),
            ],
          ),
        ),
      ),
    );
  }
}
