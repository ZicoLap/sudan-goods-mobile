import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/services/store_service.dart';
import 'package:sudan_goods/Home/widgets/shimmer_components.dart';
import 'package:sudan_goods/Home/widgets/store_card.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/store/pages/store_details_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class FeaturedStoresSection extends StatelessWidget {
  const FeaturedStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: DesignTokens.paddingPageHorizontal,
          child: Row(
            children: [
              Text(
                'Featured Stores',
                style: AppTypography.sectionTitle.copyWith(
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: DesignTokens.space8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space8,
                  vertical: DesignTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Text(
                  '⭐ Top picks',
                  style: AppTypography.caption.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space16),

        // Featured Stores List
        SizedBox(
          height: 200,
          child: FutureBuilder<List<Store>>(
            future: StoreServices().fetchFeaturedStores(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: DesignTokens.paddingPageHorizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.space16),
                  itemBuilder: (context, index) => ShimmerComponents.storeCardShimmer(),
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to load stores'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No featured stores'));
              }

              final stores = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: DesignTokens.paddingPageHorizontal,
                itemCount: stores.length,
                separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.space16),
                itemBuilder: (context, index) {
                  return StoreCard(
                    store: stores[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => StoreDetailsPage(storeId: stores[index].id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
