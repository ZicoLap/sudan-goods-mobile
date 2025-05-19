import 'package:flutter/material.dart';

class StoreCartCard extends StatelessWidget {
  final String storeId;
  final String storeName;
  final String? storeLogoUrl;
  final int itemCount;
  final double subtotal;
  final VoidCallback onTap;
  final VoidCallback onCheckout;

  const StoreCartCard({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.itemCount,
    required this.subtotal,
    required this.onTap,
    required this.onCheckout,
    this.storeLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏪 Store Logo + Name
              Row(
                children: [
                  storeLogoUrl != null && storeLogoUrl!.isNotEmpty
                      ? CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(storeLogoUrl!),
                        )
                      : const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.store, color: Colors.white),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 🛍️ Item Count + Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("🛍️ $itemCount items"),
                  Text(
                    "€${subtotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ Checkout Button (full-width)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Checkout This Store",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
