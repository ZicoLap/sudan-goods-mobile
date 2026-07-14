import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/Home/services/category_service.dart';
import 'package:sudan_goods/Home/widgets/all_stores_section.dart';
import 'package:sudan_goods/Home/widgets/categories_section.dart';
import 'package:sudan_goods/Home/widgets/featured_stores_section.dart';
import 'package:sudan_goods/Home/widgets/hero.carousel.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';
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

  // Active filter chips — UI only, wired to logic later
  final Set<String> _activeFilters = {};

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
      builder: (_) => const _FilterSheet(),
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
            child: _FilterBar(
              activeFilters: _activeFilters,
              onFilterTap:
                  (key) => setState(() {
                    if (_activeFilters.contains(key)) {
                      _activeFilters.remove(key);
                    } else {
                      _activeFilters.add(key);
                    }
                  }),
              onMoreTap: () => _openFilterSheet(context),
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

// ── Filter bar ─────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final Set<String> activeFilters;
  final ValueChanged<String> onFilterTap;
  final VoidCallback onMoreTap;

  const _FilterBar({
    required this.activeFilters,
    required this.onFilterTap,
    required this.onMoreTap,
  });

  static const _chips = [
    (key: 'country', label: 'Country', icon: Icons.flag_rounded),
    (key: 'minOrder', label: 'Min Order', icon: Icons.payments_rounded),
    (key: 'rating', label: 'Top Rated', icon: Icons.star_rounded),
    (
      key: 'delivery',
      label: 'Fast Delivery',
      icon: Icons.local_shipping_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
        children: [
          // Filter icon button
          GestureDetector(
            onTap: onMoreTap,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color:
                    activeFilters.isNotEmpty ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      activeFilters.isNotEmpty
                          ? AppColors.primary
                          : Colors.black.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color:
                        activeFilters.isNotEmpty
                            ? Colors.white
                            : Colors.black54,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color:
                          activeFilters.isNotEmpty
                              ? Colors.white
                              : Colors.black54,
                    ),
                  ),
                  if (activeFilters.isNotEmpty) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${activeFilters.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Quick chips
          ..._chips.map((chip) {
            final active = activeFilters.contains(chip.key);
            return GestureDetector(
              onTap: () => onFilterTap(chip.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        active
                            ? AppColors.primary
                            : Colors.black.withOpacity(0.1),
                  ),
                  boxShadow:
                      active
                          ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      chip.icon,
                      size: 13,
                      color: active ? Colors.white : Colors.black45,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      chip.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Filter bottom sheet ────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String _selectedCountry = 'All';
  double _minOrder = 0;
  double _minRating = 0;
  String _selectedDelivery = 'All';

  static const _countries = [
    'All',
    'Sudan',
    'Egypt',
    'Germany',
    'UAE',
    'Saudi Arabia',
  ];
  static const _deliveryOptions = [
    'All',
    'Under 30 min',
    'Under 1 hour',
    'Same day',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFD05000)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Filter Stores',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed:
                      () => setState(() {
                        _selectedCountry = 'All';
                        _minOrder = 0;
                        _minRating = 0;
                        _selectedDelivery = 'All';
                      }),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Country ──────────────────────────────────────────
                  _sheetSectionLabel(
                    Icons.flag_rounded,
                    'Country',
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _countries.map((c) {
                          final sel = _selectedCountry == c;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCountry = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    sel
                                        ? AppColors.primary
                                        : const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      sel
                                          ? AppColors.primary
                                          : Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? Colors.white : Colors.black54,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Min Order ─────────────────────────────────────────
                  _sheetSectionLabel(
                    Icons.payments_rounded,
                    'Minimum Order',
                    Colors.green,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            thumbColor: AppColors.primary,
                            inactiveTrackColor: AppColors.primary.withOpacity(
                              0.15,
                            ),
                            overlayColor: AppColors.primary.withOpacity(0.1),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _minOrder,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            onChanged: (v) => setState(() => _minOrder = v),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _minOrder == 0 ? 'Any' : '€${_minOrder.toInt()}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Min Rating ────────────────────────────────────────
                  _sheetSectionLabel(
                    Icons.star_rounded,
                    'Minimum Rating',
                    Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      final starVal = (i + 1).toDouble();
                      final filled = _minRating >= starVal;
                      return GestureDetector(
                        onTap:
                            () => setState(
                              () =>
                                  _minRating =
                                      _minRating == starVal ? 0 : starVal,
                            ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                filled
                                    ? Colors.amber.shade50
                                    : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  filled
                                      ? Colors.amber.shade300
                                      : Colors.black.withOpacity(0.08),
                            ),
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            size: 22,
                            color:
                                filled ? Colors.amber.shade600 : Colors.black26,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // ── Delivery Time ─────────────────────────────────────
                  _sheetSectionLabel(
                    Icons.local_shipping_rounded,
                    'Delivery Time',
                    Colors.deepOrange,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _deliveryOptions.map((d) {
                          final sel = _selectedDelivery == d;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDelivery = d),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    sel
                                        ? AppColors.primary
                                        : const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      sel
                                          ? AppColors.primary
                                          : Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? Colors.white : Colors.black54,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Apply button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFD05000)],
                  ),
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusXLarge,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusXLarge,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetSectionLabel(IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
