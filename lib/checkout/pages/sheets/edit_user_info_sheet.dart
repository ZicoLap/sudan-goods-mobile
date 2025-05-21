
// ✅ lib/domains/customer/checkout/sheets/edit_user_info_sheet.dart
import 'package:flutter/material.dart';

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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Edit Your Info", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text("Save"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
