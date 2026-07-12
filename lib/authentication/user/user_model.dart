import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sudan_goods/core/utils/date_time_converter.dart';
import 'package:sudan_goods/models/shared_models/address.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String gender;

  @TimestampConverter()
  final DateTime birthday;

  @TimestampConverter()
  final DateTime createdAt;

  final String phoneNumber;

  final List<Address> addresses;

  AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.gender,
    required this.birthday,
    required this.createdAt,
    required this.phoneNumber,
    required this.addresses,
  });

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? gender,
    DateTime? birthday,
    String? phoneNumber,
    List<Address>? addresses,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      createdAt: createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addresses: addresses ?? this.addresses,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  String get fullName => '$firstName $lastName';
}
