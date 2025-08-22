import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/services/store_service.dart';
import 'package:sudan_goods/Home/widgets/big_store_card_enhanced.dart';
import 'package:sudan_goods/Home/widgets/shimmer_components.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class AllStoresSection extends StatelessWidget {
  const AllStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: DesignTokens.paddingPageHorizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.allStoresTitle,
                style: AppTypography.sectionTitle.copyWith(
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all stores page
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: AppTypography.small.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: DesignTokens.space16),

        // Real-time store list
        StreamBuilder<List<Store>>(
          stream: StoreServices().streamAllApprovedStores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: DesignTokens.paddingPageHorizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(height: DesignTokens.space20),
                itemBuilder: (context, index) => ShimmerComponents.bigStoreCardShimmer(),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text(AppLocalizations.of(context)!.failedToLoadStores));
            }

            final stores = snapshot.data ?? [];

            if (stores.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noStoresAvailable));
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: DesignTokens.paddingPageHorizontal,
              itemCount: stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.space20),
              itemBuilder: (context, index) {
                return BigStoreCard(
                  store: stores[index],
                  onTap: () {
                    // TODO: Navigate to StoreDetailsPage
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
