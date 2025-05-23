import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sudan_goods/core/utils/date_time_converter_version2.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'cart_item_model.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  @JsonKey(ignore: true)
  final String id;

  final String userId;
  final String storeId;

  final List<CartItem> items;

  final double subtotal;
  final double deliveryFee;
  final double total;
  final double totalWeight;

  final String status; // pending, confirmed, etc.
  final String paymentStatus; // paid, failed
  final String paymentMethod; // stripe, etc.

  final String name;
  final String phone;
  final Address address;
  final String? orderNote;

  @TimestampConverter()
  final Timestamp createdAt;
  @TimestampConverter()
  final Timestamp updatedAt;

  Order({
    this.id = '',
    required this.userId,
    required this.storeId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.totalWeight,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.name,
    required this.phone,
    required this.address,
    this.orderNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
