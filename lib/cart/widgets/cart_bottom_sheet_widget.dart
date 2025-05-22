import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/checkout/pages/checkout_page.dart';
import 'package:sudan_goods/core/utils/delivery_fee_helper.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class CartBottomSheet extends StatelessWidget {
  final String storeId;

  const CartBottomSheet({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context);
    final List<CartItem> items = cart.getItemsByStore(storeId);
    final double subtotal = cart.getSubtotal(storeId);
    final double totalWeight = cart.getTotalWeight(storeId);

    if (items.isEmpty) {
      return const Center(child: Text("No items in this cart."));
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              FutureBuilder<Store>(
                future: cart.getStoreDetails(storeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final store = snapshot.data!;
                  final double deliveryFee = calculateDeliveryFee(
                    store: store,
                    subtotal: subtotal,
                    totalWeight: totalWeight,
                  );
                  final double total = subtotal + deliveryFee;
                  final bool canCheckout = subtotal >= store.minimumOrderAmount;

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${store.name}\'s Cart',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        // Cart Items
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 16),
                            itemBuilder: (_, i) {
                              final item = items[i];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(
                                          "€${item.price.toStringAsFixed(2)} × ${item.quantity} = €${item.totalPrice.toStringAsFixed(2)}",
                                          style: TextStyle(color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () => cart.updateQuantity(
                                          storeId,
                                          item.productId,
                                          item.quantity - 1,
                                        ),
                                      ),
                                      Text('${item.quantity}'),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => cart.updateQuantity(
                                          storeId,
                                          item.productId,
                                          item.quantity + 1,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => cart.removeItem(storeId, item.productId),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const Divider(height: 32),

                        // Totals
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              _buildPriceRow("Subtotal", subtotal),
                              _buildWeightRow("Total Weight", totalWeight),
                              _buildPriceRow("Delivery Fee", deliveryFee),
                              const SizedBox(height: 4),
                              const Divider(),
                              const SizedBox(height: 4),
                              _buildPriceRow("Total", total, isBold: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Checkout Button
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!canCheckout)
                                  Text(
                                    "Minimum order is €${store.minimumOrderAmount.toStringAsFixed(2)}",
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canCheckout
                                        ? Colors.orange.shade700
                                        : Colors.grey.shade400,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: canCheckout
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => CheckoutPage(
                                                store: store,
                                                subtotal: subtotal,
                                                totalWeight: totalWeight,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: const Text(
                                    "Checkout",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeightRow(String label, double weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text("${weight.toStringAsFixed(2)} kg"),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            "€${value.toStringAsFixed(2)}",
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
