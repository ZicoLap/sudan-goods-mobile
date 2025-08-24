import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/Home/services/category_service.dart';
import 'package:sudan_goods/Home/widgets/all_stores_section.dart';
import 'package:sudan_goods/Home/widgets/categories_section.dart';
import 'package:sudan_goods/Home/widgets/featured_stores_section.dart';
import 'package:sudan_goods/Home/widgets/hero.carousel.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/cart/pages/cart_overview_page.dart';
import 'package:sudan_goods/models/store/category_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/Home/controller/store_filter_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryService().fetchActiveCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
              Colors.grey.shade50,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: DesignTokens.paddingPageHorizontal.copyWith(
                    top: DesignTokens.space16,
                    bottom: DesignTokens.space8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.homeGreeting,
                        style: AppTypography.small.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: DesignTokens.space4),
                          Text(
                            AppLocalizations.of(context)!.deliveringTo('Gießen'),
                            style: AppTypography.locationText.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Hero Banner
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space8,
                  ),
                  child: HeroCarousel(),
                ),

                const SizedBox(height: DesignTokens.sectionSpacingMedium),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    final selectedId = context.select<StoreFilterController, String>((c) => c.selectedCategoryId);
                    final onSelect = context.read<StoreFilterController>().selectCategory;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CategoriesSection(
                        categories: const [],
                        selectedCategoryId: selectedId,
                        onCategorySelected: onSelect,
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(AppLocalizations.of(context)!.failedToLoadCategories),
                      );
                    }

                    final categories = snapshot.data ?? [];
                    final allCategory = Category(
                      id: 'all',
                      name: AppLocalizations.of(context)!.allStoresTitle,
                      isActive: true,
                      isFeatured: false,
                      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                    );
                    final categoriesWithAll = [allCategory, ...categories];
                    return CategoriesSection(
                      categories: categoriesWithAll,
                      selectedCategoryId: selectedId,
                      onCategorySelected: onSelect,
                    );
                  },
                ),

                const SizedBox(height: DesignTokens.sectionSpacingMedium),
                FeaturedStoresSection(),

                const SizedBox(height: DesignTokens.sectionSpacingLarge),
                AllStoresSection(),

                const SizedBox(height: 100), // Leave space for FAB and bottom nav
              ],
            ),
          ),
        ),
      ),

      // Floating Cart Button with Modern Design
      floatingActionButton: Consumer<CartController>(
        builder: (context, cart, child) {
          final cartCount = cart.storeCarts.length;

          return Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(35),
                    onTap: () {
                      // Placeholder action
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CartOverviewPage(),
                      ),
                    );
                    },
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        cartCount > 99 ? '99+' : '$cartCount',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}


