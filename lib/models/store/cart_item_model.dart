import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItem {
  final String productId;
  final String storeId;
  final String name;
  final String? imageUrl;
  final double price;
  final double weight; // 🟢 Add this
  int quantity;

  CartItem({
    required this.productId,
    required this.storeId,
    required this.name,
    required this.price,
    required this.weight, // 🟢 Make sure this is required
    required this.quantity,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  double get totalWeight => weight * quantity; // 🟢 NEW

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
