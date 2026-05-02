import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

/// Slim cart reference stored in Firestore.
///
/// Contains only the product reference and quantity.
/// All display data (price, name, stock, imageUrl, weight) is fetched
/// live from the products collection via [CartController.watchCartWithProducts].
@JsonSerializable()
class CartItem {
  final String productId;
  final String storeId;
  int quantity;

  CartItem({
    required this.productId,
    required this.storeId,
    required this.quantity,
  });

  /// Creates a [CartItem] from a JSON map.
  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  /// Converts this [CartItem] to a JSON map for persistence.
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
