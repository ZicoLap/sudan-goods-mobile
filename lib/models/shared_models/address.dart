import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final String street;
  final String city;
  final String country;
  final String postalCode;
  final String? label;

  Address({
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
    this.label,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
