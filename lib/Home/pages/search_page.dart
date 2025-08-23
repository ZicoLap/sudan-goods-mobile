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
        return Padding(
          padding: EdgeInsets.only(
            left: DesignTokens.space20,
            right: DesignTokens.space20,
            top: DesignTokens.space20,
            bottom: MediaQuery.of(context).viewInsets.bottom + DesignTokens.space20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(l10n.wantedSheetTitle, style: AppTypography.heading6, textAlign: TextAlign.center),
              const SizedBox(height: DesignTokens.space16),
              TextField(
                controller: _wantedNameCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.wantedProductNameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space12),
              TextField(
                controller: _wantedNotesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.wantedNotesLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              ElevatedButton(
                onPressed: () async {
                  final name = _wantedNameCtrl.text.trim();
                  final notes = _wantedNotesCtrl.text.trim().isEmpty ? null : _wantedNotesCtrl.text.trim();
                  if (name.isEmpty) return;
                  try {
                    await _wantedService.submitWantedRequest(productName: name, notes: notes);
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
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                ),
                child: Text(l10n.submitRequest, style: AppTypography.bodyLarge.copyWith(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.searchTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSubmitted,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_query.isEmpty)
              Text(AppLocalizations.of(context)!.searchEmptyPrompt)
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.searchResultsFor(_query),
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
                          child: Text(AppLocalizations.of(context)!.clearSearch),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    Expanded(
                      child: FutureBuilder<List<StoreWithProducts>>(
                        future: _resultsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          final results = snapshot.data ?? [];
                          if (results.isEmpty) {
                            final l10n = AppLocalizations.of(context)!;
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l10n.searchNoResultsTitle(_query), style: AppTypography.bodyBold),
                                    const SizedBox(height: DesignTokens.space8),
                                    Text(l10n.searchNoResultsSubtitle, textAlign: TextAlign.center),
                                    const SizedBox(height: DesignTokens.space16),
                                    ElevatedButton(
                                      onPressed: _openWantedSheet,
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                      child: Text(l10n.wantedCTA, style: const TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: results.length,
                            separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.space16),
                            itemBuilder: (context, index) {
                              final group = results[index];
                              return _StoreSection(group: group);
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
    );
  }
}

class _StoreSection extends StatelessWidget {
  final StoreWithProducts group;
  const _StoreSection({required this.group});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store header
        BigStoreCard(store: group.store),
        const SizedBox(height: DesignTokens.space12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space12),
          child: Text(AppLocalizations.of(context)!.matchingProducts, style: AppTypography.bodyBold),
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
              selector: (_, c) => c.getProductQuantity(product.storeId, product.id),
              builder: (context, qty, _) {
                return ProductGridCard(
                  product: product,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => ProductDetailsBottomSheet(product: product),
                    );
                  },
                  onAdd: () {
                    final price = (product.discountPrice != null && product.discountPrice! > 0)
                        ? product.discountPrice!
                        : product.price;
                    cart.addItem(
                      CartItem(
                        productId: product.id,
                        storeId: product.storeId,
                        name: product.name,
                        price: price,
                        weight: product.weight,
                        quantity: 1,
                        imageUrl: product.images.isNotEmpty ? product.images.first : null,
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
