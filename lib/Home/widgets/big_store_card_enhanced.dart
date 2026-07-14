import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sudan_goods/home/widgets/shimmer_components.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/store/pages/store_details_page.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class BigStoreCard extends StatefulWidget {
  final Store store;
  final VoidCallback? onTap;

  const BigStoreCard({super.key, required this.store, this.onTap});

  @override
  State<BigStoreCard> createState() => _BigStoreCardState();
}

class _BigStoreCardState extends State<BigStoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: RepaintBoundary(
        child: GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreDetailsPage(storeId: widget.store.id),
                ),
              ),
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _animationController.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _animationController.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _animationController.reverse();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  _isPressed
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cover + overlaid badges + floating logo ────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cover
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  (widget.store.coverThumbUrl?.isNotEmpty ==
                                          true
                                      ? widget.store.coverThumbUrl
                                      : widget.store.coverImageUrl) ??
                                  '',
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => ShimmerComponents.shimmerWrapper(
                                    child: Container(color: Colors.white),
                                  ),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(
                                        Icons.store_rounded,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                            // Bottom scrim
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 80,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Open / Closed badge — top start
                            PositionedDirectional(
                              top: 10,
                              start: 12,
                              child: _badge(
                                label:
                                    widget.store.isOpen
                                        ? AppLocalizations.of(
                                          context,
                                        )!.storeOpen
                                        : AppLocalizations.of(
                                          context,
                                        )!.storeClosed,
                                color:
                                    widget.store.isOpen
                                        ? const Color(0xFF1DB954)
                                        : Colors.black54,
                                dot: true,
                              ),
                            ),
                            // Rating — top end
                            if (widget.store.rating > 0)
                              PositionedDirectional(
                                top: 10,
                                end: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.52),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 12,
                                        color: Color(0xFFFFD700),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        widget.store.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (widget.store.ratingCount > 0) ...[
                                        const SizedBox(width: 2),
                                        Text(
                                          '(${widget.store.ratingCount})',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white.withOpacity(
                                              0.75,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            // Store name on scrim
                            PositionedDirectional(
                              bottom: 10,
                              start: 12,
                              end: 60,
                              child: Text(
                                widget.store.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Floating logo overlapping cover bottom
                    if ((widget.store.logoThumbUrl ?? widget.store.logoUrl) !=
                        null)
                      PositionedDirectional(
                        bottom: -20,
                        end: 16,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl:
                                  (widget.store.logoThumbUrl?.isNotEmpty == true
                                      ? widget.store.logoThumbUrl
                                      : widget.store.logoUrl) ??
                                  '',
                              fit: BoxFit.cover,
                              errorWidget:
                                  (_, __, ___) => Container(
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.store_rounded,
                                      size: 22,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // ── Info block ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (widget.store.description?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            widget.store.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ),
                      // Tags
                      if (widget.store.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children:
                                widget.store.tags
                                    .take(3)
                                    .map(
                                      (tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.07,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.18),
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      // Bottom info row
                      Row(
                        children: [
                          // Location
                          Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${widget.store.address.city}, ${widget.store.address.country}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Min order pill
                          if (widget.store.minimumOrderAmount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FFF4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFBBF7D0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.shopping_basket_rounded,
                                    size: 11,
                                    color: Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.minOrderWithAmount(
                                      '€${widget.store.minimumOrderAmount.toStringAsFixed(0)}',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required String label,
    required Color color,
    bool dot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
