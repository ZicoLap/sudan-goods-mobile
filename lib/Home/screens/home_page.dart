/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/home/services/category_service.dart';
import 'package:sudan_goods/home/widgets/all_stores_section.dart';
import 'package:sudan_goods/home/widgets/categories_section.dart';
import 'package:sudan_goods/home/widgets/featured_stores_section.dart';
import 'package:sudan_goods/home/widgets/hero.carousel.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/models/store/category_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Helper method to build navigation items
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? AppColors.primary : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppColors.primary : Colors.grey.shade600,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to show placeholder messages
  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon! ✨'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

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
            colors: [Colors.grey.shade50, Colors.white, Colors.grey.shade50],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
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

                const SizedBox(
                  height: 100,
                ), // Leave space for FAB and bottom nav
              ],
            ),
          ),
        ),
      ),

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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Cart feature coming soon! 🛒'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ⬇ Enhanced Bottom Navigation Bar with Modern Design
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: BottomAppBar(
            color: Colors.transparent,
            shape: const CircularNotchedRectangle(),
            surfaceTintColor: Colors.transparent,
            notchMargin: 12.0,
            elevation: 0,
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: "Home",
                    isActive: true,
                    onTap: () => _showPlaceholder(context, "Home"),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    label: "Orders",
                    isActive: false,
                    onTap: () => _showPlaceholder(context, "Orders"),
                  ),
                  const SizedBox(width: 50), // Space for FAB
                  _buildNavItem(
                    context,
                    icon: Icons.tune_outlined,
                    activeIcon: Icons.tune,
                    label: "Settings",
                    isActive: false,
                    onTap: () => _showPlaceholder(context, "Settings"),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: "Profile",
                    isActive: false,
                    onTap: () => _showPlaceholder(context, "Profile"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */