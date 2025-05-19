// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  storeId: json['storeId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  discountPrice: (json['discountPrice'] as num?)?.toDouble(),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  category: json['category'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  isAvailable: json['isAvailable'] as bool,
  weight: (json['weight'] as num).toDouble(),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  isFeatured: json['isFeatured'] as bool? ?? false,
  collectionIds:
      (json['collectionIds'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'storeId': instance.storeId,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'discountPrice': instance.discountPrice,
  'images': instance.images,
  'category': instance.category,
  'quantity': instance.quantity,
  'isAvailable': instance.isAvailable,
  'weight': instance.weight,
  'isFeatured': instance.isFeatured,
  'collectionIds': instance.collectionIds,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
