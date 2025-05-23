// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  userId: json['userId'] as String,
  storeId: json['storeId'] as String,
  items:
      (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  totalWeight: (json['totalWeight'] as num).toDouble(),
  status: json['status'] as String,
  paymentStatus: json['paymentStatus'] as String,
  paymentMethod: json['paymentMethod'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  address: Address.fromJson(json['address'] as Map<String, dynamic>),
  orderNote: json['orderNote'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'userId': instance.userId,
  'storeId': instance.storeId,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'subtotal': instance.subtotal,
  'deliveryFee': instance.deliveryFee,
  'total': instance.total,
  'totalWeight': instance.totalWeight,
  'status': instance.status,
  'paymentStatus': instance.paymentStatus,
  'paymentMethod': instance.paymentMethod,
  'name': instance.name,
  'phone': instance.phone,
  'address': instance.address.toJson(),
  'orderNote': instance.orderNote,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
