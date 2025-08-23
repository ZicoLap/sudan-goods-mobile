import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/services/store_service.dart';
import 'package:sudan_goods/Home/widgets/big_store_card_enhanced.dart';
import 'package:sudan_goods/Home/widgets/shimmer_components.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/Home/controller/store_filter_controller.dart';

class AllStoresSection extends StatefulWidget {
  const AllStoresSection({super.key});

  @override
  State<AllStoresSection> createState() => _AllStoresSectionState();
}

class _AllStoresSectionState extends State<AllStoresSection> {
  List<Store>? _lastStores;

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<StoreFilterController>();
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
          stream: filter.isAll
              ? StoreServices().streamAllApprovedStores()
              : StoreServices().streamApprovedStoresByCategory(filter.selectedCategoryId),
          builder: (context, snapshot) {
            // Cache last non-empty data for smoother transitions
            if (snapshot.hasData) {
              _lastStores = snapshot.data;
            }

            final isWaiting = snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError && !isWaiting;
            final stores = snapshot.data ?? _lastStores ?? [];

            if (hasError) {
              return Center(child: Text(AppLocalizations.of(context)!.failedToLoadStores));
            }

            if (stores.isEmpty && isWaiting) {
              // Initial load
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: DesignTokens.paddingPageHorizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(height: DesignTokens.space20),
                itemBuilder: (context, index) => ShimmerComponents.bigStoreCardShimmer(),
              );
            }

            if (stores.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noStoresAvailable));
            }

            // Show last data while loading new category, with subtle progress indicator
            return Stack(
              children: [
                ListView.separated(
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
                ),
                if (isWaiting)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
