import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sudan_goods/home/widgets/shimmer_components.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;

  const StoreCard({super.key, required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasCover = store.coverImageUrl?.isNotEmpty == true;
    final hasLogo = (store.logoThumbUrl ?? store.logoUrl)?.isNotEmpty == true;
    final logoUrl =
        store.logoThumbUrl?.isNotEmpty == true
            ? store.logoThumbUrl!
            : (store.logoUrl ?? '');

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover image with overlays ──────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover
                      hasCover
                          ? CachedNetworkImage(
                            imageUrl: store.coverImageUrl!,
                            fit: BoxFit.cover,
                            placeholder:
                                (_, __) => ShimmerComponents.shimmerWrapper(
                                  child: Container(color: Colors.white),
                                ),
                            errorWidget: (_, __, ___) => _coverFallback(),
                          )
                          : _coverFallback(),
                      // Bottom gradient scrim
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.55),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Open / Closed badge — top-start
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                store.isOpen
                                    ? const Color(0xFF1DB954)
                                    : Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            store.isOpen ? 'Open' : 'Closed',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Rating chip — top-end
                      if (store.rating > 0)
                        PositionedDirectional(
                          top: 8,
                          end: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 11,
                                  color: Color(0xFFFFD700),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  store.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Store name overlaid on scrim
                      PositionedDirectional(
                        bottom: 7,
                        start: 8,
                        end: 8,
                        child: Text(
                          store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Info row ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Row(
                  children: [
                    // Logo bubble
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade100,
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child:
                            hasLogo
                                ? CachedNetworkImage(
                                  imageUrl: logoUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => _logoFallback(),
                                )
                                : _logoFallback(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // City + min order
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  store.address.city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (store.minimumOrderAmount > 0) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Min €${store.minimumOrderAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverFallback() => Container(
    color: Colors.grey.shade200,
    child: const Center(
      child: Icon(Icons.store_rounded, size: 36, color: Colors.grey),
    ),
  );

  Widget _logoFallback() => Container(
    color: Colors.grey.shade100,
    child: const Icon(Icons.store_rounded, size: 18, color: Colors.grey),
  );
}
