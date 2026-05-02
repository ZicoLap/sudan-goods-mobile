import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'package:sudan_goods/models/store/delivery_rules_model.dart';

import '../../core/utils/date_time_converter_version4.dart';

part 'store_model.g.dart';

/// Store domain model representing a merchant listed in the app.
///
/// This model maps Firestore documents to strongly-typed Dart objects
/// and supports JSON serialization via json_serializable.
@JsonSerializable(explicitToJson: true)
class Store {
  /// Unique identifier for the store.
  final String id; //

  /// Name of the store.
  final String name; //

  /// Optional description of the store.
  final String? description; //

  /// ID of the store owner.
  final String storeOwnerId;

  /// Optional email address of the store.
  final String? email; //

  /// Optional phone number of the store.
  final String? phoneNumber; //

  /// Optional logo URL of the store.
  final String? logoUrl; //
  final String? coverImageUrl; //
  /// Optional thumbnail URLs for optimized list rendering.
  final String? logoThumbUrl; //
  final String? coverThumbUrl; //
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

  /// Creates a new [Store] instance.
  ///
  /// Only a subset of fields are required; others have sensible defaults
  /// or are optional depending on the business configuration.
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
    this.logoThumbUrl,
    this.coverThumbUrl,
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

  /// Returns a copy of this [Store] with the provided overrides.
  ///
  /// Currently only [id] can be overridden because other fields are
  /// considered immutable after creation in this context.
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
      logoThumbUrl: logoThumbUrl,
      coverThumbUrl: coverThumbUrl,
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

  /// Builds a [Store] from a Firestore [DocumentSnapshot].
  ///
  /// The document ID is injected into the model's [id] field.
  factory Store.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Store.fromJson(data).copyWith(id: doc.id);
  }

  /// Deserializes a [Store] from JSON/Map, usually from Firestore data.
  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  /// Serializes this [Store] to a JSON/Map for persistence.
  Map<String, dynamic> toJson() => _$StoreToJson(this);
}
