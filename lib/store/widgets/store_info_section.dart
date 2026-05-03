import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/follow/presentation/controllers/follow_controller.dart';
import 'package:sudan_goods/follow/domain/entities/store_summary.dart';

class StoreInfoSection extends StatelessWidget {
  final Store store;
  const StoreInfoSection({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space20,
        vertical: DesignTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name and follow button row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: AppTypography.heading4.copyWith(
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                    // Tags if available
                    if (store.tags.isNotEmpty) ...[
                      const SizedBox(height: DesignTokens.space8),
                      Wrap(
                        spacing: DesignTokens.space8,
                        runSpacing: DesignTokens.space4,
                        children:
                            store.tags.take(3).map((tag) {
                              return _TagChip(label: tag);
                            }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              _FollowButton(store: store),
            ],
          ),

          // Description in subtle container
          if (store.description != null && store.description!.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.space12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.space12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Text(
                store.description!,
                style: AppTypography.body.copyWith(
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],

          const SizedBox(height: DesignTokens.space16),

          // Meta info row - Min order and rating
          Row(
            children: [
              _MetaChip(
                icon: Icons.shopping_bag_outlined,
                iconGradient: [Colors.teal.shade400, Colors.teal.shade600],
                label: 'Min. Order',
                value: '€${store.minimumOrderAmount.toStringAsFixed(0)}',
              ),
              const SizedBox(width: DesignTokens.space12),
              _MetaChip(
                icon: Icons.star_rounded,
                iconGradient: [Colors.amber.shade400, Colors.orange.shade500],
                label: '${store.rating.toStringAsFixed(1)}',
                value: '(${store.ratingCount} reviews)',
                isHighlighted: store.rating >= 4.0,
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.space16),

          // Location row
          _LocationRow(
            country: store.address.country,
            city: store.address.city,
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final Store store;
  const _FollowButton({required this.store});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Warm up the stream so that first build has the latest state ASAP.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<FollowController?>();
      ctrl?.watchIsFollowing(widget.store.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<FollowController?>(context, listen: false);

    // If controller not available yet (e.g., user not loaded), show disabled button
    if (ctrl == null) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          elevation: 0,
        ),
        child: const Text(
          '+ Follow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    final storeId = widget.store.id;
    final initial = ctrl.getCachedFollowing(storeId) ?? false;

    return StreamBuilder<bool>(
      stream: ctrl.watchIsFollowing(storeId),
      initialData: initial,
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        return ElevatedButton(
          onPressed:
              _busy
                  ? null
                  : () async {
                    setState(() => _busy = true);
                    final targetState = !isFollowing; // optimistic target
                    await ctrl.toggleFollow(
                      storeId,
                      knownSummary: StoreSummary.fromStore(widget.store),
                    );
                    if (!mounted) return;
                    setState(() => _busy = false);
                    if (ctrl.lastError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not update follow: ${ctrl.lastError}',
                          ),
                        ),
                      );
                    } else {
                      // Success snackbar
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(DesignTokens.space12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusLarge,
                            ),
                          ),
                          backgroundColor:
                              targetState
                                  ? Colors.green.shade600
                                  : Colors.grey.shade800,
                          duration: const Duration(seconds: 2),
                          content: Row(
                            children: [
                              Icon(
                                targetState
                                    ? Icons.check_circle
                                    : Icons.remove_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: DesignTokens.space8),
                              Expanded(
                                child: Text(
                                  targetState
                                      ? "You're now following ${widget.store.name}"
                                      : 'Unfollowed ${widget.store.name}',
                                  style: AppTypography.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.space16,
              vertical: DesignTokens.space8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            elevation: 0,
          ),
          child: Text(
            isFollowing ? 'Following' : (_busy ? '...' : '+ Follow'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

// ── Tag Chip ────────────────────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.small.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Modern Meta Chip ─────────────────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String label;
  final String value;
  final bool isHighlighted;

  const _MetaChip({
    required this.icon,
    required this.iconGradient,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.space12),
        decoration: BoxDecoration(
          color:
              isHighlighted ? const Color(0xFFFFF8E7) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          border: Border.all(
            color:
                isHighlighted
                    ? Colors.amber.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: iconGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconGradient.last.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: DesignTokens.space8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.small.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.bodyBold.copyWith(
                      color:
                          isHighlighted
                              ? Colors.orange.shade700
                              : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Location Row ─────────────────────────────────────────────────────────────
class _LocationRow extends StatelessWidget {
  final String country;
  final String city;

  const _LocationRow({required this.country, required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: DesignTokens.space12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: DesignTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Location',
                  style: AppTypography.small.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$city, $country',
                  style: AppTypography.bodyBold.copyWith(color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.blue.shade400,
          ),
        ],
      ),
    );
  }
}
