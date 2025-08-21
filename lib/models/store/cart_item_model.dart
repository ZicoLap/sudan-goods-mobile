import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

/// Represents an item placed into a store-scoped shopping cart.
///
/// This model is JSON-serializable and used to persist cart state locally
/// and in Firestore. The [weight] is used to compute delivery costs based
/// on the total weight across items.
@JsonSerializable()
class CartItem {
  final String productId;
  final String storeId;
  final String name;
  final String? imageUrl;
  final double price;
  final double weight; // 🟢 Add this
  int quantity;

  /// Creates a [CartItem] with a required [productId], [storeId], [name],
  /// unit [price], unit [weight], and [quantity].
  CartItem({
    required this.productId,
    required this.storeId,
    required this.name,
    required this.price,
    required this.weight, // 🟢 Make sure this is required
    required this.quantity,
    this.imageUrl,
  });

  /// Line total price: `price * quantity`.
  double get totalPrice => price * quantity;

  /// Line total weight: `weight * quantity`.
  double get totalWeight => weight * quantity; // 🟢 NEW

  /// Creates a [CartItem] from a JSON map.
  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
  /// Converts this [CartItem] to a JSON map for persistence.
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
