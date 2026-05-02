import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/cart/widgets/cart_bottom_sheet_widget.dart';
import 'package:sudan_goods/cart/widgets/store_cart_card.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class CartOverviewPage extends StatelessWidget {
  const CartOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final storeCarts = cartController.storeCarts;
    final l10n = AppLocalizations.of(context)!;

    if (storeCarts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.cartTitle,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.06), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: DesignTokens.paddingPageHorizontal.add(
                const EdgeInsets.symmetric(vertical: DesignTokens.space32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBubble(Icons.shopping_cart_outlined),
                  const SizedBox(height: DesignTokens.space16),
                  Text(
                    l10n.cartEmpty,
                    style: AppTypography.heading5,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🛒 ${l10n.cartsAllTitle}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.06), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: DesignTokens.paddingPageHorizontal.add(
            const EdgeInsets.only(top: DesignTokens.space32, bottom: 120),
          ),
          itemCount: storeCarts.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _iconBubble(Icons.shopping_cart_rounded),
                    const SizedBox(height: DesignTokens.space12),
                    Text(
                      '🛒 ${l10n.cartsAllTitle}',
                      style: AppTypography.heading4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.space16),
                  ],
                ),
              );
            }

            final storeId = storeCarts.keys.elementAt(index - 1);
            final items = storeCarts[storeId]!;
            final itemCount = items.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            );

            return FutureBuilder(
              future: cartController.getStoreDetails(storeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: LinearProgressIndicator(),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(l10n.failedToLoadStoreData),
                  );
                }

                final store = snapshot.data!;

                return Dismissible(
                  key: Key(storeId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text(l10n.removeCart),
                            content: Text(l10n.removeCartConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.remove),
                              ),
                            ],
                          ),
                    );
                  },
                  onDismissed: (_) {
                    cartController.clearCart(storeId);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.cartRemoved)));
                  },
                  child: StoreCartCard(
                    storeId: storeId,
                    storeName: store.name,
                    storeLogoUrl: store.logoUrl,
                    itemCount: itemCount,
                    subtotal: 0.0,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => CartBottomSheet(storeId: storeId),
                      );
                    },
                    onCheckout: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CartBottomSheet(storeId: storeId),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        minimum: DesignTokens.paddingPageHorizontal,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // No multi-store checkout flow yet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.comingSoonWithFeature(l10n.checkoutAllCarts),
                  ),
                ),
              );
            },
            child: Text(l10n.checkoutAllCarts),
          ),
        ),
      ),
    );
  }
}

Widget _iconBubble(IconData icon) {
  return Container(
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
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: 36),
  );
}
