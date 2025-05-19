import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/Home/services/category_service.dart';
import 'package:sudan_goods/Home/widgets/all_stores_section.dart';
import 'package:sudan_goods/Home/widgets/categories_section.dart';
import 'package:sudan_goods/Home/widgets/featured_stores_section.dart';
import 'package:sudan_goods/Home/widgets/hero.carousel.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/cart/pages/cart_overview_page.dart';
import 'package:sudan_goods/models/store/category_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sudan shops',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.location_searching, color: Colors.black),
          onPressed: () {
            print('Back button pressed');
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.search_rounded, color: Colors.black),
            onPressed: () {
              // TODO: Navigate to search page
            },
          ),
        ],
      ),

      // 🧱 Main Scrollable Content wrapped in SafeArea
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Delivering to: Gießen',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Hero Banner Placeholder
              HeroCarousel(),

              /* SizedBox(height: 16),
              PopularProductsSection(), */
              SizedBox(height: 16),
              FutureBuilder<List<Category>>(
                future: CategoryService().fetchActiveCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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

              SizedBox(height: 16),
              FeaturedStoresSection(),

              SizedBox(height: 16),
              AllStoresSection(),

              SizedBox(height: 80), // Leave space for FAB
            ],
          ),
        ),
      ),

      // 🛒 Floating Cart Button with Badge
      floatingActionButton: Consumer<CartController>(
        builder: (context, cart, child) {
          final cartCount = cart.storeCarts.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 80,
                width: 80,
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ⬇ Bottom Bar with SafeArea for safe padding
      bottomNavigationBar: SafeArea(
        bottom: false,

        child: BottomAppBar(
          color: Colors.orange,
          shape: const CircularNotchedRectangle(),
          surfaceTintColor: Colors.white,
          notchMargin: 8.0,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.home, color: Colors.black),
                  onPressed: () {
                    // TODO: Navigate to Home
                  },
                ),
                IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.list_alt, color: Colors.black),
                  onPressed: () {
                    // TODO: Navigate to Orders
                  },
                ),
                const SizedBox(width: 40), // Space for FAB in the middle
                IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    // TODO: Navigate to Profile
                  },
                ),
                IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.person, color: Colors.black),
                  onPressed: () {
                    // TODO: Navigate to Profile
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
