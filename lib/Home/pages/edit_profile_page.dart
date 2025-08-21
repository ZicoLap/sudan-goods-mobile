import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'John Doe');
  final _handleController = TextEditingController(text: '@john_doe');
  final _bioController = TextEditingController(text: 'Loves Sudanese spices and coffee.');

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.space16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  boxShadow: DesignTokens.shadowSmall,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _changePhoto,
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundImage: AssetImage('assets/images/default_profile.jpg'),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Profile photo', style: AppTypography.bodyBold),
                              const SizedBox(height: 6),
                              Text('Tap to change photo', style: AppTypography.small.copyWith(color: Colors.black54)),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _changePhoto,
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              Container(
                padding: const EdgeInsets.all(DesignTokens.space16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  boxShadow: DesignTokens.shadowSmall,
                ),
                child: Column(
                  children: [
                    _textField('Name', _nameController, TextInputType.name),
                    const SizedBox(height: DesignTokens.space12),
                    _textField('Handle', _handleController, TextInputType.text, prefixText: '@'),
                    const SizedBox(height: DesignTokens.space12),
                    _textField('Bio', _bioController, TextInputType.multiline, maxLines: 3),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _comingSoon('Save changes'),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save changes'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, TextInputType type, {int maxLines = 1, String? prefixText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.cardTitle),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            filled: true,
            fillColor: const Color(0xFFFFEAD4), // subtle brand-like input fill
            hintText: label,
          ),
        ),
      ],
    );
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Change photo', style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }
}
