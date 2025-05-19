// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
  id: json['id'] as String,
  name: json['name'] as String,
  storeOwnerId: json['storeOwnerId'] as String,
  address: Address.fromJson(json['address'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  description: json['description'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  logoUrl: json['logoUrl'] as String?,
  coverImageUrl: json['coverImageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
  isApproved: json['isApproved'] as bool? ?? false,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  isOpen: json['isOpen'] as bool? ?? true,
  minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble() ?? 0.0,
  storeTypes:
      (json['storeTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isFeatured: json['isFeatured'] as bool? ?? false,
  categoryIds:
      (json['categoryIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'storeOwnerId': instance.storeOwnerId,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'logoUrl': instance.logoUrl,
  'coverImageUrl': instance.coverImageUrl,
  'address': instance.address.toJson(),
  'tags': instance.tags,
  'isActive': instance.isActive,
  'isApproved': instance.isApproved,
  'rating': instance.rating,
  'ratingCount': instance.ratingCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isOpen': instance.isOpen,
  'minimumOrderAmount': instance.minimumOrderAmount,
  'storeTypes': instance.storeTypes,
  'isFeatured': instance.isFeatured,
  'categoryIds': instance.categoryIds,
};
