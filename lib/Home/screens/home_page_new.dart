import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/home/services/category_service.dart';
import 'package:sudan_goods/home/widgets/all_stores_section.dart';
import 'package:sudan_goods/home/widgets/categories_section.dart';
import 'package:sudan_goods/home/widgets/featured_stores_section.dart';
import 'package:sudan_goods/home/widgets/hero.carousel.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/cart/pages/cart_overview_page.dart';
import 'package:sudan_goods/models/store/category_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/home/controllers/store_filter_controller.dart';
import 'package:sudan_goods/home/widgets/store_filter_bar.dart';
import 'package:sudan_goods/home/widgets/store_filter_sheet.dart';

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

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StoreFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final userName =
        userProvider.isUserLoaded ? userProvider.currentUser.fullName : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient hero header ───────────────────────────────────
          SliverToBoxAdapter(child: _HomeHeroBanner(userName: userName)),

          // ── Filter chips row ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: StoreFilterBar(
              onMoreFilters: () => _openFilterSheet(context),
            ),
          ),

          // ── Hero carousel ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                child: HeroCarousel(),
              ),
            ),
          ),

          // ── Categories ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: DesignTokens.sectionSpacingMedium,
              ),
              child: FutureBuilder<List<Category>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  final selectedId = context
                      .select<StoreFilterController, String>(
                        (c) => c.selectedCategoryId,
                      );
                  final onSelect =
                      context.read<StoreFilterController>().selectCategory;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CategoriesSection(
                      categories: const [],
                      selectedCategoryId: selectedId,
                      onCategorySelected: onSelect,
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(l10n.failedToLoadCategories));
                  }
                  final categories = snapshot.data ?? [];
                  final allCategory = Category(
                    id: 'all',
                    name: l10n.allStoresTitle,
                    isActive: true,
                    isFeatured: false,
                    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                  );
                  return CategoriesSection(
                    categories: [allCategory, ...categories],
                    selectedCategoryId: selectedId,
                    onCategorySelected: onSelect,
                  );
                },
              ),
            ),
          ),

          // ── Featured stores ───────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: DesignTokens.sectionSpacingMedium),
              child: FeaturedStoresSection(),
            ),
          ),

          // ── All stores ────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: DesignTokens.sectionSpacingLarge),
              child: AllStoresSection(),
            ),
          ),

          // Bottom padding (FAB + nav bar)
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),

      // ── Cart FAB ──────────────────────────────────────────────────────
      floatingActionButton: Consumer<CartController>(
        builder: (context, cart, _) {
          final count = cart.storeCarts.length;
          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartOverviewPage()),
                ),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFFD05000)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}

// ── Hero banner wave clipper ───────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 12,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 24,
      size.width,
      size.height - 8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) => false;
}

// ── Home hero banner ───────────────────────────────────────────────────────────

class _HomeHeroBanner extends StatelessWidget {
  final String userName;
  const _HomeHeroBanner({required this.userName});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().split(' ').first;
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8C38), AppColors.primary, Color(0xFFBF4000)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Decorative circles ──────────────────────────────────────
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              right: 20,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            // ── Content ─────────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Top row: greeting + icons ────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.55),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child:
                                userName.isNotEmpty
                                    ? Text(
                                      _initials(userName),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.person_rounded,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Greeting text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _greeting(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.72),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                firstName.isNotEmpty
                                    ? '$firstName 👋'
                                    : 'Welcome 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification bell
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Filter UI has been extracted into reusable StoreFilterBar and StoreFilterSheet widgets.
