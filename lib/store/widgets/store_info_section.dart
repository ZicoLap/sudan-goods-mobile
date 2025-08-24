
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
          // Store name and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: AppTypography.heading5,
                ),
              ),
              _FollowButton(store: store),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),

          // Description
          if (store.description != null && store.description!.isNotEmpty)
            Text(
              store.description!,
              style: AppTypography.body,
            ),

          const SizedBox(height: DesignTokens.space12),

          // Min order and rating
          Row(
            children: [
              _MetaChip(
                icon: Icons.shopping_basket,
                iconColor: Colors.green,
                label: 'Min. €${store.minimumOrderAmount.toStringAsFixed(0)}',
              ),
              const SizedBox(width: DesignTokens.space12),
              _MetaChip(
                icon: Icons.star,
                iconColor: Colors.amber,
                label: '${store.rating.toStringAsFixed(1)} (${store.ratingCount})',
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.space12),

          // Location
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
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
                child: const Icon(Icons.location_on, color: Colors.white, size: 14),
              ),
              const SizedBox(width: DesignTokens.space8),
              Text(
                '${store.address.country} / ${store.address.city}',
                style: AppTypography.small,
              ),
            ],
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
          onPressed: _busy
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
                      SnackBar(content: Text('Could not update follow: ${ctrl.lastError}')),
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
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                        ),
                        backgroundColor: targetState
                            ? Colors.green.shade600
                            : Colors.grey.shade800,
                        duration: const Duration(seconds: 2),
                        content: Row(
                          children: [
                            Icon(
                              targetState ? Icons.check_circle : Icons.remove_circle,
                              color: Colors.white,
                            ),
                            const SizedBox(width: DesignTokens.space8),
                            Expanded(
                              child: Text(
                                targetState
                                    ? "You're now following ${widget.store.name}"
                                    : 'Unfollowed ${widget.store.name}',
                                style: AppTypography.body.copyWith(color: Colors.white),
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _MetaChip({required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space12,
        vertical: DesignTokens.space8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.9),
                  iconColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 12),
          ),
          const SizedBox(width: DesignTokens.space8),
          Text(label, style: AppTypography.small),
        ],
      ),
    );
  }
}
