import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'package:sudan_goods/models/store/delivery_rules_model.dart';

import '../../core/utils/date_time_converter_version4.dart';

part 'store_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Store {
  final String id; //
  final String name; //
  final String? description; //
  final String storeOwnerId;
  final String? email; //
  final String? phoneNumber; //
  final String? logoUrl; //
  final String? coverImageUrl; //
  final Address address; //
  final List<String> tags; //
  final bool isActive; //
  final bool isApproved; //
  final double rating; // average rating like 4.5
  final int ratingCount; //

  @TimestampConverter()
  final DateTime createdAt; //

  @TimestampConverter()
  final DateTime? updatedAt; //
  final bool isOpen; //
  final double minimumOrderAmount; //
  final List<String> storeTypes; //
  final bool isFeatured;
  final List<String> categoryIds; //
  final double? freeDeliveryOver; //
  final List<DeliveryRule> deliveryPricing; //

  Store({
    required this.id,
    required this.name,
    required this.storeOwnerId,
    required this.address,
    required this.createdAt,
    this.description,
    this.email,
    this.phoneNumber,
    this.logoUrl,
    this.coverImageUrl,
    this.tags = const [],
    this.isActive = true,
    this.isApproved = false,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.updatedAt,
    this.isOpen = true,
    this.minimumOrderAmount = 0.0,
    this.storeTypes = const [],
    this.isFeatured = false,
    this.categoryIds = const [],
    this.freeDeliveryOver,
    this.deliveryPricing = const [],
  });

  Store copyWith({String? id}) {
    return Store(
      id: id ?? this.id,
      name: name,
      storeOwnerId: storeOwnerId,
      address: address,
      createdAt: createdAt,
      description: description,
      email: email,
      phoneNumber: phoneNumber,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      tags: tags,
      isActive: isActive,
      isApproved: isApproved,
      rating: rating,
      ratingCount: ratingCount,
      updatedAt: updatedAt,
      isOpen: isOpen,
      minimumOrderAmount: minimumOrderAmount,
      storeTypes: storeTypes,
      isFeatured: isFeatured,
      categoryIds: categoryIds,
      freeDeliveryOver: freeDeliveryOver ?? freeDeliveryOver,
      deliveryPricing: deliveryPricing,
    );
  }

  factory Store.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Debug print
    print('Store document data: $data');
    return Store.fromJson(data).copyWith(id: doc.id);
  }

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);
}
