import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sudan_goods/core/utils/date_time_converter_version2.dart';

part 'collection_model.g.dart';

@JsonSerializable()
class Collection {
  @JsonKey(ignore: true)
  final String id; // Not stored in Firestore, set from doc.id

  final String storeId;
  final String name;
  final String imageUrl;

  @TimestampConverter()
  final Timestamp createdAt;

  Collection({
    this.id = '',
    required this.storeId,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
  });

  // Factory from Firestore JSON
  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  // Custom helper from document snapshot
  factory Collection.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Collection.fromJson(data).copyWith(id: doc.id);
  }

  // Copy with to set ID
  Collection copyWith({String? id}) {
    return Collection(
      id: id ?? this.id,
      storeId: storeId,
      name: name,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}
