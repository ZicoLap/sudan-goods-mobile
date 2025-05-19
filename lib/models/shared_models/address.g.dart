// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  id: json['id'] as String,
  label: json['label'] as String,
  street: json['street'] as String,
  city: json['city'] as String,
  country: json['country'] as String,
  postalCode: json['postalCode'] as String,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'street': instance.street,
  'city': instance.city,
  'country': instance.country,
  'postalCode': instance.postalCode,
};
