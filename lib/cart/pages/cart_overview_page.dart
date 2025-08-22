import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/cart/widgets/cart_bottom_sheet_widget.dart';
import 'package:sudan_goods/cart/widgets/store_cart_card.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class CartOverviewPage extends StatelessWidget {
  const CartOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final storeCarts = cartController.storeCarts;
    final l10n = AppLocalizations.of(context)!;

    if (storeCarts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.cartTitle)),
        body: Center(child: Text(l10n.cartEmpty)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🛒 ${l10n.cartsAllTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: storeCarts.length,

        itemBuilder: (context, index) {
          final storeId = storeCarts.keys.elementAt(index);
          final items = storeCarts[storeId]!;
          final subtotal = cartController.getSubtotal(storeId);
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
                          content: Text(
                            l10n.removeCartConfirmation,
                          ),
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
                  subtotal: subtotal,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => CartBottomSheet(storeId: storeId),
                    );
                  },
                  onCheckout: () {
                    // TODO: implement checkout flow
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              // TODO: handle "checkout all"
            },
            child: Text(
              l10n.checkoutAllCarts,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
