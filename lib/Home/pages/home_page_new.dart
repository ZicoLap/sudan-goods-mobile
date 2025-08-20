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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudan Goods'),
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
                        'Good day! 👋',
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
                            'Delivering to Gießen',
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
                  future: CategoryService().fetchActiveCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CategoriesSection(categories: []);
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Failed to load categories'),
                      );
                    }

                    final categories = snapshot.data ?? [];
                    return CategoriesSection(categories: categories);
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

      // 🛒 Floating Cart Button with Badge


/* 
      floatingActionButton: Consumer<CartController>(
        builder: (context, cart, child) {
          final cartCount = cart.storeCarts.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 65,
                width: 65,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CartOverviewPage(),
                      ),
                    );
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(
                    Icons.shopping_cart,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  top: -6,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),

 */

  // 🛒 Enhanced Floating Cart Button with Modern Design
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

      // ⬇ Bottom Bar with SafeArea for safe padding
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          surfaceTintColor: Colors.white,
          notchMargin: 8.0,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    // TODO: Navigate to Home
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.home, color: Colors.black, size: 22),
                      Text("Home", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Navigate to Orders
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.list_alt, color: Colors.black, size: 22),
                      Text("Orders", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 40), // Space for FAB
                InkWell(
                  onTap: () {
                    // TODO: Navigate to Settings
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.settings, color: Colors.black, size: 22),
                      Text("Settings", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Navigate to Profile
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.person, color: Colors.black, size: 22),
                      Text("Profile", style: TextStyle(fontSize: 12)),
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
}
