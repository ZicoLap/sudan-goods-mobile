import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sudan_goods/Home/widgets/shimmer_components.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/store/pages/store_details_page.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class BigStoreCard extends StatefulWidget {
  final Store store;
  final VoidCallback? onTap;

  const BigStoreCard({super.key, required this.store, this.onTap});

  @override
  State<BigStoreCard> createState() => _BigStoreCardState();
}

class _BigStoreCardState extends State<BigStoreCard> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoreDetailsPage(storeId: widget.store.id),
                  ),
                );
              },
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
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              splashColor: AppColors.primary.withOpacity(0.1),
              highlightColor: AppColors.primary.withOpacity(0.05),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  boxShadow: _isPressed 
                      ? DesignTokens.shadowSmall
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                  border: Border.all(
                    color: Colors.grey.shade100,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image with logo overlay and gradient
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(DesignTokens.radiusLarge),
                          ),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: (widget.store.coverThumbUrl?.isNotEmpty == true
                                        ? widget.store.coverThumbUrl
                                        : widget.store.coverImageUrl) ??
                                    '',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => ShimmerComponents.shimmerWrapper(
                                  child: Container(
                                    height: 180,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.store,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              // Gradient overlay for better text readability
                              Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.store.logoUrl != null)
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                                color: Colors.white,
                                boxShadow: DesignTokens.shadowSmall,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                                child: CachedNetworkImage(
                                  imageUrl: (widget.store.logoThumbUrl?.isNotEmpty == true
                                          ? widget.store.logoThumbUrl
                                          : widget.store.logoUrl) ??
                                      '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => ShimmerComponents.shimmerWrapper(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.store,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Content
                    Padding(
                      padding: DesignTokens.paddingCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + Open Status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.store.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.cardTitle.copyWith(
                                    fontSize: DesignTokens.fontSizeBodyLarge,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.store.isOpen
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                                  border: Border.all(
                                    color: widget.store.isOpen
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: widget.store.isOpen ? Colors.green : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.store.isOpen
                                          ? AppLocalizations.of(context)!.storeOpen
                                          : AppLocalizations.of(context)!.storeClosed,
                                      style: AppTypography.tag.copyWith(
                                        color: widget.store.isOpen ? Colors.green.shade700 : Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Description
                          if (widget.store.description != null &&
                              widget.store.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: DesignTokens.space8),
                              child: Text(
                                widget.store.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.cardSubtitle,
                              ),
                            ),

                          const SizedBox(height: DesignTokens.space12),

                          // Tags
                          Wrap(
                            spacing: DesignTokens.space8,
                            runSpacing: DesignTokens.space4,
                            children: widget.store.tags.take(3).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.1),
                                      AppColors.primary.withOpacity(0.05),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTypography.tag.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: DesignTokens.space12),

                          // Min. Order with enhanced styling
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.space12,
                              vertical: DesignTokens.space8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_basket_outlined,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.space8),
                                Text(
                                  AppLocalizations.of(context)!.minOrderWithAmount(
                                    '€${widget.store.minimumOrderAmount.toStringAsFixed(0)}',
                                  ),
                                  style: AppTypography.small.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: DesignTokens.space12),

                          // Location + Rating with enhanced styling
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: DesignTokens.space8),
                                    Expanded(
                                      child: Text(
                                        widget.store.address.country,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.small.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.space8,
                                  vertical: DesignTokens.space4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.store.rating.toStringAsFixed(1),
                                      style: AppTypography.small.copyWith(
                                        color: Colors.amber.shade700,
                                        fontWeight: FontWeight.w600,
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
      },
    );
  }
}
