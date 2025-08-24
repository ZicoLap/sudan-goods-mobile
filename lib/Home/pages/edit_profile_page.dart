import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'John Doe');
  final _handleController = TextEditingController(text: 'john_doe');
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.editProfile, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () => _comingSoon(AppLocalizations.of(context)!.saveChanges),
            tooltip: AppLocalizations.of(context)!.saveChanges,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Colors.white, Color(0xFFF8FBFF)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                    boxShadow: DesignTokens.shadowSmall,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _changePhoto,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.9),
                                    AppColors.primary.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: DesignTokens.shadowSmall,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const CircleAvatar(
                                  radius: 36,
                                  backgroundImage: AssetImage('assets/images/default_profile.jpg'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.profilePhoto, style: AppTypography.bodyBold),
                                const SizedBox(height: 6),
                                Text(AppLocalizations.of(context)!.tapToChangePhoto, style: AppTypography.small.copyWith(color: Colors.black54)),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _changePhoto,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: Text(AppLocalizations.of(context)!.change),
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
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                    boxShadow: DesignTokens.shadowSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _iconBubble(Icons.person_outline),
                          const SizedBox(width: DesignTokens.space12),
                          Text(AppLocalizations.of(context)!.editProfile, style: AppTypography.cardTitle),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space16),
                      _textField(AppLocalizations.of(context)!.name, _nameController, TextInputType.name),
                      const SizedBox(height: DesignTokens.space12),
                      _textField(AppLocalizations.of(context)!.handle, _handleController, TextInputType.text, prefixText: '@'),
                      const SizedBox(height: DesignTokens.space12),
                      _textField(AppLocalizations.of(context)!.bio, _bioController, TextInputType.multiline, maxLines: 3),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.space24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _comingSoon(AppLocalizations.of(context)!.saveChanges),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(AppLocalizations.of(context)!.saveChanges),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
            filled: true,
            fillColor: AppColors.inputField,
            hintText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBubble(IconData icon, {double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: size * 0.55),
      ),
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
            Text(AppLocalizations.of(ctx)!.changePhoto, style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            ListTile(
              leading: _iconBubble(Icons.photo_camera_outlined, size: 40),
              title: Text(AppLocalizations.of(ctx)!.takePhoto),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: _iconBubble(Icons.photo_library_outlined, size: 40),
              title: Text(AppLocalizations.of(ctx)!.chooseFromGallery),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoonWithFeature(feature))),
    );
  }
}
