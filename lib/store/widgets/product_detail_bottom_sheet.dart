import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/product_model.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final Product product;

  const ProductDetailsBottomSheet({super.key, required this.product});

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState
    extends State<ProductDetailsBottomSheet> {
  int quantity = 1;
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.quantity == 0;
    final price = product.discountPrice != null && product.discountPrice! > 0
        ? product.discountPrice!
        : product.price;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🖼️ Image Carousel
            Column(
              children: [
                SizedBox(
                  height: 450,
                  child: PageView.builder(
                    itemCount: product.images.isNotEmpty
                        ? product.images.length
                        : 1,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = product.images.isNotEmpty
                          ? product.images[index]
                          : null;

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  size: 80,
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                ),
                              ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // 🔘 Dots Indicator
                if (product.images.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      product.images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentImageIndex == index ? 10 : 6,
                        height: currentImageIndex == index ? 10 : 6,
                        decoration: BoxDecoration(
                          color: currentImageIndex == index
                              ? Colors.orange
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 📦 Product Name
            Text(
              product.name,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // 💰 Price and Discount
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (product.discountPrice != null &&
                    product.discountPrice! > 0)
                  Text(
                    '€${product.discountPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                if (product.discountPrice != null &&
                    product.discountPrice! > 0)
                  const SizedBox(width: 8),
                Text(
                  '€${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: product.discountPrice != null &&
                            product.discountPrice! > 0
                        ? Colors.grey
                        : Colors.black,
                    decoration: product.discountPrice != null &&
                            product.discountPrice! > 0
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 📃 Description
            Text(
              product.description,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // ➖➕ Quantity + Add Button
            Row(
              children: [
                // Quantity stepper
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(quantity.toString(),
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                        onPressed: () {
                          setState(() => quantity++);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Add to Cart Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: isOutOfStock
                        ? null
                        : () {
                            // TODO: Add to cart logic
                            Navigator.of(context).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isOutOfStock ? Colors.grey : Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      isOutOfStock
                          ? 'Out of Stock'
                          : 'Add €${(price * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
