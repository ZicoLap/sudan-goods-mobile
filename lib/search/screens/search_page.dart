import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/search/services/search_service.dart';
import 'package:sudan_goods/search/services/wanted_service.dart';
import 'package:sudan_goods/home/widgets/big_store_card_enhanced.dart';
import 'package:sudan_goods/store/widgets/product_grid_card.dart';
import 'package:sudan_goods/store/widgets/product_detail_bottom_sheet.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchService _searchService = SearchService();
  final WantedService _wantedService = WantedService();

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _wantedNameCtrl = TextEditingController();
  final TextEditingController _wantedNotesCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;
  Future<List<StoreWithProducts>>? _resultsFuture;
  String _query = '';

  static const int _minQueryLength = 2;
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _wantedNameCtrl.dispose();
    _wantedNotesCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final raw = _controller.text;
    setState(() {}); // re-render clear button

    _debounce?.cancel();

    if (raw.trim().length < _minQueryLength) {
      setState(() {
        _query = '';
        _resultsFuture = null;
      });
      return;
    }

    _debounce = Timer(_debounceDuration, () => _runSearch(raw.trim()));
  }

  void _runSearch(String q) {
    if (!mounted) return;
    setState(() {
      _query = q;
      _resultsFuture = _searchService.searchProductsGroupedByStore(q);
      _wantedNameCtrl.text = q;
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _query = '';
      _resultsFuture = null;
    });
    _searchFocus.requestFocus();
  }

  Future<void> _openWantedSheet() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _WantedSheet(
            wantedNameCtrl: _wantedNameCtrl,
            wantedNotesCtrl: _wantedNotesCtrl,
            wantedService: _wantedService,
            l10n: l10n,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero banner ───────────────────────────────────────────────
          _SearchHeroBanner(l10n: l10n),

          // ── Search bar ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.space16,
              DesignTokens.space16,
              DesignTokens.space16,
              DesignTokens.space8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                border: Border.all(color: Colors.black.withOpacity(0.07)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) {
                  if (v.trim().length >= _minQueryLength) {
                    _debounce?.cancel();
                    _runSearch(v.trim());
                  }
                },
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 15,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(
                      Icons.search_rounded,
                      color:
                          _searchFocus.hasFocus
                              ? AppColors.primary
                              : Colors.black38,
                      size: 22,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 50,
                    minHeight: 50,
                  ),
                  suffixIcon:
                      _controller.text.isNotEmpty
                          ? GestureDetector(
                            onTap: _clearSearch,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.07),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ),
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 6,
                  ),
                ),
              ),
            ),
          ),

          // ── Results header (shown when query active) ──────────────
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
                vertical: DesignTokens.space4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.searchResultsFor(_query),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black45,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.clearSearch,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child:
                _query.isEmpty
                    ? _EmptyState(onWantedTap: _openWantedSheet)
                    : FutureBuilder<List<StoreWithProducts>>(
                      future: _resultsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _SearchSkeleton();
                        }
                        if (snapshot.hasError) {
                          return _ErrorState(onRetry: () => _runSearch(_query));
                        }
                        final results = snapshot.data ?? [];
                        if (results.isEmpty) {
                          return _NoResultsState(
                            query: _query,
                            onWantedTap: _openWantedSheet,
                          );
                        }
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            DesignTokens.space16,
                            DesignTokens.space12,
                            DesignTokens.space16,
                            DesignTokens.space40,
                          ),
                          itemCount: results.length,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(height: DesignTokens.space16),
                          itemBuilder: (context, index) {
                            final group = results[index];
                            return _StoreSection(
                              key: ValueKey(group.store.id),
                              group: group,
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

// ── Search hero banner ─────────────────────────────────────────────────────────

class _SearchHeroBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _SearchHeroBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFFD05000)],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 24,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.searchTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.searchHint,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12.5,
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

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onWantedTap;
  const _EmptyState({required this.onWantedTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 34,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: DesignTokens.space20),
            const Text(
              'What are you looking for?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              l10n.searchEmptyPrompt,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black45,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space32),
            const _Dividerline(),
            const SizedBox(height: DesignTokens.space24),
            const Text(
              "Can't find what you need?",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: DesignTokens.space12),
            _WantedButton(onTap: onWantedTap, label: l10n.wantedCTA),
          ],
        ),
      ),
    );
  }
}

// ── No results state ───────────────────────────────────────────────────────────

class _NoResultsState extends StatelessWidget {
  final String query;
  final VoidCallback onWantedTap;
  const _NoResultsState({required this.query, required this.onWantedTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: DesignTokens.space20),
            Text(
              l10n.searchNoResultsTitle(query),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space8),
            const Text(
              'Try different keywords or request the product below',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black45,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space24),
            _WantedButton(onTap: onWantedTap, label: l10n.wantedCTA),
          ],
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 32,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: DesignTokens.space20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space8),
            const Text(
              'Check your connection and try again.',
              style: TextStyle(fontSize: 13, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space24),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer skeleton ───────────────────────────────────────────────────────────

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.space16,
          DesignTokens.space12,
          DesignTokens.space16,
          DesignTokens.space40,
        ),
        itemCount: 2,
        separatorBuilder:
            (_, __) => const SizedBox(height: DesignTokens.space16),
        itemBuilder: (_, __) => _SkeletonStoreSection(),
      ),
    );
  }
}

class _SkeletonStoreSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusMedium,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space16),
          // Products row
          Row(
            children: List.generate(
              2,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMedium,
                      ),
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
}

// ── Store section (card-wrapped) ───────────────────────────────────────────────

class _StoreSection extends StatelessWidget {
  final StoreWithProducts group;
  const _StoreSection({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cart = Provider.of<CartController>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusLarge),
            ),
            child: BigStoreCard(
              key: ValueKey(group.store.id),
              store: group.store,
            ),
          ),

          // Products label + count badge
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.space16,
              DesignTokens.space12,
              DesignTokens.space16,
              DesignTokens.space8,
            ),
            child: Row(
              children: [
                Text(
                  l10n.matchingProducts,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: DesignTokens.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${group.products.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Products grid
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.space12,
              0,
              DesignTokens.space12,
              DesignTokens.space16,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: DesignTokens.space12,
                crossAxisSpacing: DesignTokens.space12,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) {
                final product = group.products[index];
                return Selector<CartController, int>(
                  selector:
                      (_, c) =>
                          c.getProductQuantity(product.storeId, product.id),
                  builder: (context, qty, _) {
                    return ProductGridCard(
                      key: ValueKey(product.id),
                      product: product,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder:
                              (context) =>
                                  ProductDetailsBottomSheet(product: product),
                        );
                      },
                      onAdd: () {
                        cart.addItem(
                          CartItem(
                            productId: product.id,
                            storeId: product.storeId,
                            quantity: 1,
                          ),
                        );
                      },
                      cartQuantity: qty,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wanted sheet ───────────────────────────────────────────────────────────────

class _WantedSheet extends StatelessWidget {
  final TextEditingController wantedNameCtrl;
  final TextEditingController wantedNotesCtrl;
  final WantedService wantedService;
  final AppLocalizations l10n;

  const _WantedSheet({
    required this.wantedNameCtrl,
    required this.wantedNotesCtrl,
    required this.wantedService,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: DesignTokens.space20,
        right: DesignTokens.space20,
        top: DesignTokens.space20,
        bottom: MediaQuery.of(context).viewInsets.bottom + DesignTokens.space24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space20),

            // Header
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.wantedSheetTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        "We'll notify sellers about your request",
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space20),

            // Product name
            TextField(
              controller: wantedNameCtrl,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.wantedProductNameLabel,
                prefixIcon: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space12),

            // Notes
            TextField(
              controller: wantedNotesCtrl,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.wantedNotesLabel,
                prefixIcon: Icon(
                  Icons.notes_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space20),

            // Submit
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final name = wantedNameCtrl.text.trim();
                  final notes =
                      wantedNotesCtrl.text.trim().isEmpty
                          ? null
                          : wantedNotesCtrl.text.trim();
                  if (name.isEmpty) return;
                  try {
                    await wantedService.submitWantedRequest(
                      productName: name,
                      notes: notes,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.wantedSubmitted),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusMedium,
                            ),
                          ),
                        ),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.wantedSubmitFailed),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  l10n.submitRequest,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusXLarge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared small helpers ───────────────────────────────────────────────────────

class _WantedButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const _WantedButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

class _Dividerline extends StatelessWidget {
  const _Dividerline();

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: Colors.black.withOpacity(0.06));
}
