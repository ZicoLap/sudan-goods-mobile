import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/services/store_service.dart';
import 'package:sudan_goods/Home/widgets/shimmer_components.dart';
import 'package:sudan_goods/Home/widgets/store_card.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/store/pages/store_details_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class FeaturedStoresSection extends StatelessWidget {
  const FeaturedStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: DesignTokens.paddingPageHorizontal,
          child: Row(
            children: [
              // Icon bubble
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C38), AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.featuredStores,
                style: AppTypography.sectionTitle.copyWith(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 11,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      AppLocalizations.of(context)!.topPicksBadge,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space16),

        SizedBox(
          height: 185,
          child: FutureBuilder<List<Store>>(
            future: StoreServices().fetchFeaturedStores(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: DesignTokens.paddingPageHorizontal,
                  itemCount: 3,
                  separatorBuilder:
                      (_, __) => const SizedBox(width: DesignTokens.space16),
                  itemBuilder: (_, __) => ShimmerComponents.storeCardShimmer(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.failedToLoadStores),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.noFeaturedStores),
                );
              }
              final stores = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: DesignTokens.paddingPageHorizontal,
                itemCount: stores.length,
                separatorBuilder:
                    (_, __) => const SizedBox(width: DesignTokens.space16),
                itemBuilder:
                    (context, index) => StoreCard(
                      key: ValueKey(stores[index].id),
                      store: stores[index],
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => StoreDetailsPage(
                                    storeId: stores[index].id,
                                  ),
                            ),
                          ),
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}
