// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  uid: json['uid'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  role: json['role'] as String,
  gender: json['gender'] as String,
  birthday: DateTime.parse(json['birthday'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  phoneNumber: json['phoneNumber'] as String,
  addresses:
      (json['addresses'] as List<dynamic>)
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'role': instance.role,
  'gender': instance.gender,
  'birthday': instance.birthday.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'phoneNumber': instance.phoneNumber,
  'addresses': instance.addresses.map((e) => e.toJson()).toList(),
};
