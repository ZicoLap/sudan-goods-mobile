import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/services/store_service.dart';
import 'package:sudan_goods/Home/widgets/big_store_card_enhanced.dart';
import 'package:sudan_goods/Home/widgets/shimmer_components.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
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
                    colors: [AppColors.primary, Color(0xFFBF4000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.store_mall_directory_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.allStoresTitle,
                style: AppTypography.sectionTitle.copyWith(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
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
              ),
            ],
          ),
        ),
        SizedBox(height: DesignTokens.space16),

        // Real-time store list
        StreamBuilder<List<Store>>(
          stream:
              filter.isAll
                  ? StoreServices().streamAllApprovedStores()
                  : StoreServices().streamApprovedStoresByCategory(
                    filter.selectedCategoryId,
                  ),
          builder: (context, snapshot) {
            // Cache last non-empty data for smoother transitions
            if (snapshot.hasData) {
              _lastStores = snapshot.data;
            }

            final isWaiting =
                snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError && !isWaiting;
            final stores = snapshot.data ?? _lastStores ?? [];

            if (hasError) {
              return Padding(
                padding: DesignTokens.paddingPageHorizontal,
                child: Center(
                  child: Text(AppLocalizations.of(context)!.failedToLoadStores),
                ),
              );
            }

            if (stores.isEmpty && isWaiting) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: DesignTokens.paddingPageHorizontal,
                itemCount: 3,
                separatorBuilder:
                    (_, __) => const SizedBox(height: DesignTokens.space20),
                itemBuilder: (_, __) => ShimmerComponents.bigStoreCardShimmer(),
              );
            }

            if (stores.isEmpty) {
              return Padding(
                padding: DesignTokens.paddingPageHorizontal,
                child: Center(
                  child: Text(AppLocalizations.of(context)!.noStoresAvailable),
                ),
              );
            }

            return Stack(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: DesignTokens.paddingPageHorizontal,
                  itemCount: stores.length,
                  separatorBuilder:
                      (_, __) => const SizedBox(height: DesignTokens.space20),
                  itemBuilder:
                      (context, index) => BigStoreCard(
                        key: ValueKey(stores[index].id),
                        store: stores[index],
                      ),
                ),
                if (isWaiting)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
