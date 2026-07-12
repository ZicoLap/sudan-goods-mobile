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
  birthday: const TimestampConverter().fromJson(json['birthday'] as Timestamp),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
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
  'birthday': const TimestampConverter().toJson(instance.birthday),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'phoneNumber': instance.phoneNumber,
  'addresses': instance.addresses.map((e) => e.toJson()).toList(),
};
