import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

/// Represents a postal address used for delivery and contact details.
///
/// Serializable via json_serializable. Use [label] to store a friendly name
/// such as "Home" or "Work".
@JsonSerializable()
class Address {
  final String street;
  final String city;
  final String country;
  final String postalCode;
  final String? label;

  /// Creates an [Address].
  ///
  /// All fields except [label] are required.
  Address({
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
    this.label,
  });

  /// Builds an [Address] instance from a JSON map.
  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  /// Converts this [Address] into a JSON map compatible with Firestore.
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
