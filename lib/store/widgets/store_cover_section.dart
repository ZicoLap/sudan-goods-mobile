import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class StoreCoverSection extends StatelessWidget {
  final Store store;
  const StoreCoverSection({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space20,
        vertical: DesignTokens.space12,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          child: Stack(
            children: [
              // Cover Image with shimmer loading
              SizedBox(
                height: isTablet ? 400 : 250,
                width: double.infinity,
                child:
                    store.coverImageUrl != null &&
                            store.coverImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: store.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.store,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                        )
                        : Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/sudanese_spices.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
              ),

              // Soft gradient overlay for depth
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // Store Logo with enhanced gradient ring (bottom left)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.95),
                        const Color(0xFFD05000).withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ClipOval(
                        child:
                            store.logoUrl != null && store.logoUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: store.logoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(color: Colors.white),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: Colors.grey.shade100,
                                        child: Icon(
                                          Icons.storefront,
                                          size: 32,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                )
                                : Container(
                                  color: Colors.grey.shade100,
                                  child: Icon(
                                    Icons.storefront,
                                    size: 32,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
              ),

              // Modern pill-shaped Open/Closed Badge (bottom right)
              Positioned(
                bottom: 20,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          store.isOpen
                              ? [Colors.green.shade500, Colors.green.shade400]
                              : [Colors.red.shade500, Colors.red.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color:
                            store.isOpen
                                ? Colors.green.withValues(alpha: 0.4)
                                : Colors.red.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        store.isOpen ? 'OPEN' : 'CLOSED',
                        style: AppTypography.smallBold.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
