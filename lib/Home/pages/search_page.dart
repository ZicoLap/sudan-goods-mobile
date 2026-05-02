import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/Home/services/search_service.dart';
import 'package:sudan_goods/Home/services/wanted_service.dart';
import 'package:sudan_goods/Home/widgets/big_store_card_enhanced.dart';
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
  Future<List<StoreWithProducts>>? _resultsFuture;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _wantedNameCtrl = TextEditingController();
  final TextEditingController _wantedNotesCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Rebuild when the user types to toggle the clear icon visibility
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _wantedNameCtrl.dispose();
    _wantedNotesCtrl.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    final q = value.trim();
    setState(() {
      _query = q;
      if (_query.isEmpty) {
        _resultsFuture = null;
      } else {
        _resultsFuture = _searchService.searchProductsGroupedByStore(_query);
        _wantedNameCtrl.text = _query;
      }
    });
  }

  // no-op

  Future<void> _openWantedSheet() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7F9FC), Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: DesignTokens.space20,
              right: DesignTokens.space20,
              top: DesignTokens.space20,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  DesignTokens.space20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusRound,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  Text(
                    l10n.wantedSheetTitle,
                    style: AppTypography.heading6,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  TextField(
                    controller: _wantedNameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: l10n.wantedProductNameLabel,
                      prefixIcon: Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: AppColors.inputField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusRound,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space12),
                  TextField(
                    controller: _wantedNotesCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.wantedNotesLabel,
                      prefixIcon: Icon(
                        Icons.notes_outlined,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: AppColors.inputField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusRound,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = _wantedNameCtrl.text.trim();
                        final notes =
                            _wantedNotesCtrl.text.trim().isEmpty
                                ? null
                                : _wantedNotesCtrl.text.trim();
                        if (name.isEmpty) return;
                        try {
                          await _wantedService.submitWantedRequest(
                            productName: name,
                            notes: notes,
                          );
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(l10n.wantedSubmitted)),
                            );
                          }
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(l10n.wantedSubmitFailed)),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusRound,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.send, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.submitRequest,
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.searchTitle,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FC), Colors.white, Color(0xFFF7F9FC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern pill-shaped search field with subtle shadow
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputField,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                    boxShadow: DesignTokens.shadowSmall,
                  ),
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSubmitted,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      suffixIcon:
                          _controller.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _controller.clear();
                                  });
                                },
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
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space16),
                if (_query.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 48,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: DesignTokens.space12),
                          Text(
                            l10n.searchEmptyPrompt,
                            style: AppTypography.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: DesignTokens.space16),
                          ElevatedButton(
                            onPressed: _openWantedSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusRound,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.wantedCTA,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.searchResultsFor(_query),
                                style: AppTypography.bodyBold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                  _query = '';
                                  _resultsFuture = null;
                                });
                              },
                              child: Text(l10n.clearSearch),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.space8),
                        Expanded(
                          child: FutureBuilder<List<StoreWithProducts>>(
                            future: _resultsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }
                              final results = snapshot.data ?? [];
                              if (results.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.searchNoResultsTitle(_query),
                                          style: AppTypography.bodyBold,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          height: DesignTokens.space8,
                                        ),
                                        Text(
                                          l10n.searchNoResultsSubtitle,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          height: DesignTokens.space16,
                                        ),
                                        ElevatedButton(
                                          onPressed: _openWantedSheet,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                          ),
                                          child: Text(
                                            l10n.wantedCTA,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                itemCount: results.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(
                                      height: DesignTokens.space16,
                                    ),
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreSection extends StatelessWidget {
  final StoreWithProducts group;
  const _StoreSection({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store header
        BigStoreCard(key: ValueKey(group.store.id), store: group.store),
        const SizedBox(height: DesignTokens.space12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space12),
          child: Text(
            AppLocalizations.of(context)!.matchingProducts,
            style: AppTypography.bodyBold,
          ),
        ),
        const SizedBox(height: DesignTokens.space8),

        // Matching products grid
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space12),
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
                  (_, c) => c.getProductQuantity(product.storeId, product.id),
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
      ],
    );
  }
}
