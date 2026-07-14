import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';
import 'package:sudan_goods/models/shared_models/address.dart';

class ManageAddressesPage extends StatelessWidget {
  const ManageAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final addresses =
        userProvider.isUserLoaded
            ? userProvider.currentUser.addresses
            : <Address>[];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.manageAddresses,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
          top: false,
          child:
              addresses.isEmpty
                  ? _EmptyState(l10n: l10n)
                  : ListView.separated(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    itemCount: addresses.length,
                    separatorBuilder:
                        (_, __) => const SizedBox(height: DesignTokens.space12),
                    itemBuilder:
                        (context, index) => _AddressCard(
                          address: addresses[index],
                          index: index,
                          isDefault: index == 0,
                        ),
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context, l10n),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addAddress),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddAddressSheet(l10n: l10n),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              l10n.noAddressesYet,
              style: AppTypography.bodyBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              l10n.addAddressPrompt,
              style: AppTypography.small.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatefulWidget {
  final Address address;
  final int index;
  final bool isDefault;

  const _AddressCard({
    required this.address,
    required this.index,
    required this.isDefault,
  });

  @override
  State<_AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<_AddressCard> {
  bool _isDeleting = false;

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            title: Text(l10n.deleteAddress),
            content: Text(l10n.deleteAddressConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(dialogCtx, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _isDeleting = true);
    try {
      await context.read<UserProvider>().removeAddress(widget.index);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.failedToDeleteAddress)));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final a = widget.address;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(
          color:
              widget.isDefault
                  ? AppColors.primary.withOpacity(0.4)
                  : Colors.black.withOpacity(0.06),
        ),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
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
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (a.label != null && a.label!.isNotEmpty) ...[
                        Text(a.label!, style: AppTypography.bodyBold),
                        const SizedBox(width: DesignTokens.space8),
                      ],
                      if (widget.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusRound,
                            ),
                          ),
                          child: Text(
                            l10n.defaultAddress,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (a.label != null && a.label!.isNotEmpty)
                    const SizedBox(height: 2),
                  Text(a.street, style: AppTypography.body),
                  Text(
                    '${a.postalCode} ${a.city}, ${a.country}',
                    style: AppTypography.small.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            _isDeleting
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _confirmDelete(context, l10n),
                  visualDensity: VisualDensity.compact,
                ),
          ],
        ),
      ),
    );
  }
}

class _AddAddressSheet extends StatefulWidget {
  final AppLocalizations l10n;
  const _AddAddressSheet({required this.l10n});

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final address = Address(
      label: _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim(),
    );

    try {
      await context.read<UserProvider>().addAddress(address);
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _isSaving = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.failedToSaveAddress)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
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
                    ),
                    child: const Icon(
                      Icons.add_location_alt_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Text(l10n.addAddress, style: AppTypography.heading6),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space20),
              _field(
                controller: _labelCtrl,
                label: l10n.addressLabel,
                hint: l10n.addressLabelHint,
                icon: Icons.label_outline,
                required: false,
              ),
              const SizedBox(height: DesignTokens.space12),
              _field(
                controller: _streetCtrl,
                label: l10n.street,
                hint: l10n.streetHint,
                icon: Icons.signpost_outlined,
                required: true,
              ),
              const SizedBox(height: DesignTokens.space12),
              _field(
                controller: _cityCtrl,
                label: l10n.city,
                hint: l10n.cityHint,
                icon: Icons.location_city_outlined,
                required: true,
              ),
              const SizedBox(height: DesignTokens.space12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _postalCtrl,
                      label: l10n.postalCode,
                      hint: '',
                      icon: Icons.pin_outlined,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: _field(
                      controller: _countryCtrl,
                      label: l10n.country,
                      hint: '',
                      icon: Icons.flag_outlined,
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusLarge,
                      ),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            l10n.saveAddress,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                ),
              ),
              const SizedBox(height: DesignTokens.space8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool required,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.inputField,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator:
          required
              ? (v) =>
                  (v == null || v.trim().isEmpty)
                      ? widget.l10n.fieldRequired
                      : null
              : null,
    );
  }
}
