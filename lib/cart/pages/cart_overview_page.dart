import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/cart/widgets/cart_bottom_sheet_widget.dart';
import 'package:sudan_goods/cart/widgets/store_cart_card.dart';

class CartOverviewPage extends StatelessWidget {
  const CartOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final storeCarts = cartController.storeCarts;

    if (storeCarts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Your Cart")),
        body: const Center(child: Text("Your cart is empty.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🛒 All Carts",
          style: TextStyle(fontWeight: FontWeight.bold),
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
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text("Failed to load store data"),
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
                          title: const Text("Remove Cart"),
                          content: const Text(
                            "Are you sure you want to remove this store's cart?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Remove"),
                            ),
                          ],
                        ),
                  );
                },
                onDismissed: (_) {
                  cartController.clearCart(storeId);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Cart removed")));
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
        minimum: const EdgeInsets.all(12),
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
            child: const Text(
              "Checkout All Carts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
