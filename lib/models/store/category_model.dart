import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sudan_goods/core/utils/date_time_converter.dart';

part 'category_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Category {
  final String id;
  final String name;
  final String? imageUrl;
  /// Optional thumbnail for faster list rendering
  final String? imageThumbUrl;
  final bool isActive;
  final bool isFeatured;

  @TimestampConverter()
  final DateTime createdAt;

  @TimestampConverter()
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    this.imageUrl,
    this.imageThumbUrl,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
