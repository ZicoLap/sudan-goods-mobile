import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/checkout/pages/checkout_page.dart';
import 'package:sudan_goods/core/utils/delivery_fee_helper.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class CartBottomSheet extends StatefulWidget {
  final String storeId;

  const CartBottomSheet({super.key, required this.storeId});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  late final Future<Store> _storeFuture;

  @override
  void initState() {
    super.initState();
    final cart = Provider.of<CartController>(context, listen: false);
    _storeFuture = cart.getStoreDetails(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: true);
    final l10n = AppLocalizations.of(context)!;
    final List<CartItem> items = cart.getItemsByStore(widget.storeId);
    final double subtotal = cart.getSubtotal(widget.storeId);
    final double totalWeight = cart.getTotalWeight(widget.storeId);

    if (items.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Colors.white, Color(0xFFF8FBFF)],
            stops: [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.95),
                    AppColors.primary.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              l10n.cartIsEmptyTitle,
              style: AppTypography.bodyBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.addItemsToBeginCheckout,
              style: AppTypography.small.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space16),
          ],
        ),
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FBFF), Colors.white, Color(0xFFF8FBFF)],
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: DesignTokens.paddingSection,
                  child: FutureBuilder<Store>(
                    future: _storeFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(
                          child: Text(
                            l10n.failedToLoadStore,
                            style: AppTypography.body,
                          ),
                        );
                      }

                      final store = snapshot.data!;
                      final double deliveryFee = calculateDeliveryFee(
                        store: store,
                        subtotal: subtotal,
                        totalWeight: totalWeight,
                      );
                      final double total = subtotal + deliveryFee;
                      final bool canCheckout =
                          subtotal >= store.minimumOrderAmount;
                      return CustomScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Header
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if ((store.logoUrl ?? '').isNotEmpty)
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundImage: NetworkImage(
                                          store.logoUrl!,
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary.withOpacity(
                                                0.95,
                                              ),
                                              AppColors.primary.withOpacity(
                                                0.75,
                                              ),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.store_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    const SizedBox(width: DesignTokens.space12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            store.name,
                                            style: AppTypography.heading6,
                                          ),
                                          Text(
                                            l10n.itemsCount(
                                              items.fold<int>(
                                                0,
                                                (s, i) => s + i.quantity,
                                              ),
                                            ),
                                            style: AppTypography.small.copyWith(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        cart.clearCart(store.id);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.cartCleared),
                                          ),
                                        );
                                        Navigator.of(context).maybePop();
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                      label: Text(l10n.clear),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: DesignTokens.space16),
                              ],
                            ),
                          ),

                          // Items with separators
                          SliverList(
                            delegate: SliverChildBuilderDelegate((context, i) {
                              final item = items[i];
                              return Column(
                                children: [
                                  _CartItemRow(
                                    storeId: widget.storeId,
                                    item: item,
                                  ),
                                  if (i != items.length - 1)
                                    const Divider(height: 24),
                                ],
                              );
                            }, childCount: items.length),
                          ),

                          // Totals and actions
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: DesignTokens.space12),
                                Container(
                                  padding: DesignTokens.paddingCard,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusLarge,
                                    ),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.06),
                                    ),
                                    boxShadow: DesignTokens.shadowSmall,
                                  ),
                                  child: Column(
                                    children: [
                                      _priceRow(l10n.subtotal, subtotal),
                                      _weightRow(l10n.totalWeight, totalWeight),
                                      _priceRow(l10n.deliveryFee, deliveryFee),
                                      const Divider(height: 24),
                                      _priceRow(
                                        l10n.total,
                                        total,
                                        isBold: true,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: DesignTokens.space12),
                                if (!canCheckout)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      l10n.minOrderWithAmount(
                                        '€${store.minimumOrderAmount.toStringAsFixed(2)}',
                                      ),
                                      style: AppTypography.small.copyWith(
                                        color: Colors.orange.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                const SizedBox(height: DesignTokens.space12),
                                SafeArea(
                                  top: false,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: IgnorePointer(
                                      ignoring: !canCheckout,
                                      child: Opacity(
                                        opacity: canCheckout ? 1 : 0.6,
                                        child: GestureDetector(
                                          onTap:
                                              canCheckout
                                                  ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (_) => CheckoutPage(
                                                              store: store,
                                                              subtotal:
                                                                  subtotal,
                                                              totalWeight:
                                                                  totalWeight,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                  : null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    DesignTokens.radiusRound,
                                                  ),
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primary.withOpacity(
                                                    0.95,
                                                  ),
                                                  AppColors.primary.withOpacity(
                                                    0.75,
                                                  ),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              l10n.checkout,
                                              style: AppTypography.bodyLarge
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _priceRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? AppTypography.bodyBold : AppTypography.body,
          ),
          Text(
            '€${value.toStringAsFixed(2)}',
            style: isBold ? AppTypography.bodyBold : AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _weightRow(String label, double weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(
            '${weight.toStringAsFixed(2)} ${AppLocalizations.of(context)!.kg}',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final String storeId;
  final CartItem item;
  const _CartItemRow({required this.storeId, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(),
        const SizedBox(width: DesignTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(item.name, style: AppTypography.bodyBold),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed:
                        () => context.read<CartController>().removeItem(
                          storeId,
                          item.productId,
                        ),
                    tooltip: AppLocalizations.of(context)!.remove,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '€${item.price.toStringAsFixed(2)}',
                    style: AppTypography.small.copyWith(color: Colors.black54),
                  ),
                  if (item.weight > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '· ${item.weight.toStringAsFixed(2)} ${AppLocalizations.of(context)!.kg}',
                      style: AppTypography.small.copyWith(
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Selector<CartController, int>(
                selector:
                    (_, c) => c.getProductQuantity(storeId, item.productId),
                builder: (context, qty, _) {
                  final total = item.price * qty;
                  return Row(
                    children: [
                      _stepper(context, qty),
                      const Spacer(),
                      Text(
                        '€${total.toStringAsFixed(2)}',
                        style: AppTypography.bodyBold,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final imageUrl = item.imageUrl;
    final radius = BorderRadius.circular(DesignTokens.radiusMedium);
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child:
            imageUrl == null || imageUrl.isEmpty
                ? const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.black26,
                )
                : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.black26,
                      ),
                ),
      ),
    );
  }

  Widget _stepper(BuildContext context, int qty) {
    final cart = context.read<CartController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cart.updateQuantity(storeId, item.productId, qty - 1),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.95),
                    AppColors.primary.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.remove, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text('$qty', style: AppTypography.bodyBold),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => cart.updateQuantity(storeId, item.productId, qty + 1),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.95),
                    AppColors.primary.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
