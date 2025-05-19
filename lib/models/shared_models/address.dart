import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final String id; // Unique ID (e.g. generated with UUID or Firestore doc ID)
  final String label; // "Home", "Work", etc.
  final String street;
  final String city;
  final String country;
  final String postalCode;

  Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
  });

  factory Address.empty() => Address(
  id: '',
  label: '',
  street: '',
  city: '',
  country: '',
  postalCode: '',
);

  Address copyWith({
    String? id,
    String? label,
    String? street,
    String? city,
    String? country,
    String? postalCode,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }


  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);


}
