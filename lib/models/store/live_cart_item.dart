/// UI-only model — never stored in Firestore.
///
/// Merges a cart reference (productId + quantity) with live product data
/// fetched from the products collection. Used only for display.
class LiveCartItem {
  final String productId;
  final String storeId;
  final int quantity;
  final String name;
  final double price;
  final String? imageUrl;
  final double weight;
  final int stock;
  final bool isAvailable;

  const LiveCartItem({
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.name,
    required this.price,
    required this.weight,
    required this.stock,
    required this.isAvailable,
    this.imageUrl,
  });

  /// Line total price: `price * quantity`.
  double get lineTotal => price * quantity;

  /// Line total weight: `weight * quantity`.
  double get lineTotalWeight => weight * quantity;

  /// Whether the cart quantity is covered by available stock.
  bool get hasEnoughStock => stock >= quantity;

  LiveCartItem copyWith({int? quantity}) {
    return LiveCartItem(
      productId: productId,
      storeId: storeId,
      quantity: quantity ?? this.quantity,
      name: name,
      price: price,
      imageUrl: imageUrl,
      weight: weight,
      stock: stock,
      isAvailable: isAvailable,
    );
  }
}
