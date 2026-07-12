// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String,
  name: json['name'] as String,
  isActive: json['isActive'] as bool,
  isFeatured: json['isFeatured'] as bool,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  imageUrl: json['imageUrl'] as String?,
  imageThumbUrl: json['imageThumbUrl'] as String?,
  updatedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['updatedAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'imageThumbUrl': instance.imageThumbUrl,
  'isActive': instance.isActive,
  'isFeatured': instance.isFeatured,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.updatedAt,
    const TimestampConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
