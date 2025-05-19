import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sudan_goods/core/utils/date_time_converter_version2.dart';

part 'product_model.g.dart'; // 🟡 Important for generated file

@JsonSerializable(explicitToJson: true)
class Product {
  @JsonKey(ignore: true)
  final String id; // We manually set this from doc.id, not saved in Firestore

  final String storeId;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String? category;
  final int quantity;
  final bool isAvailable;
  final double weight;
  final bool isFeatured;
  final List<String> collectionIds; // ✅ new field

  @TimestampConverter()
  final Timestamp createdAt;

  @TimestampConverter()
  final Timestamp updatedAt;

  Product({
    this.id = '',
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    this.category,
    required this.quantity,
    required this.isAvailable,
    required this.weight,
    required this.createdAt,
    required this.updatedAt,
    this.isFeatured = false,
    required this.collectionIds, // ✅ new field
  });

  // 🛠️ From JSON (for Firestore)
  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  // 🛠️ To JSON (for Firestore)
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // 🛠️ Custom helper: from Firestore document
  factory Product.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product.fromJson(data).copyWith(id: doc.id);
  }

  // 🛠️ Custom helper: copyWith to manually set id
  Product copyWith({String? id}) {
    return Product(
      id: id ?? this.id,
      storeId: storeId,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      images: images,
      category: category,
      quantity: quantity,
      isAvailable: isAvailable,
      weight: weight,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFeatured: isFeatured,
      collectionIds: collectionIds, // ✅ new field
    );
  }
}
