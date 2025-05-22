import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/product_model.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final int cartQuantity;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
    this.cartQuantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! > 0;
    final isOutOfStock = product.quantity == 0;

    return SizedBox(
      height: 260, // Fixed card height to prevent overflow
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🖼️ Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          product.images.isNotEmpty ? product.images.first : '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 48),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 📦 Info: name, stock, price
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text( '${product.weight.toString()} kg',),
                          Text(
                            product.quantity > 0
                                ? '${product.quantity} In Stock'
                                : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isOutOfStock ? Colors.red : Colors.black87,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '€${(hasDiscount ? product.discountPrice! : product.price).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color:
                                      hasDiscount ? Colors.red : Colors.black,
                                ),
                              ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '€${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ➕ Add to cart button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: product.quantity == 0 ? null : onAdd,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          cartQuantity > 0 ? Colors.black87 : Colors.orange,
                    ),
                    child: cartQuantity > 0
                        ? Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            child: Text(
                              '$cartQuantity',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
