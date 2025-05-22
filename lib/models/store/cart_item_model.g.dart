// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  productId: json['productId'] as String,
  storeId: json['storeId'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  weight: (json['weight'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'productId': instance.productId,
  'storeId': instance.storeId,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'price': instance.price,
  'weight': instance.weight,
  'quantity': instance.quantity,
};
