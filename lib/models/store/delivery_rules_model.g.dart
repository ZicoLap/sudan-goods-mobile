// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_rules_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryRule _$DeliveryRuleFromJson(Map<String, dynamic> json) => DeliveryRule(
  maxWeight: (json['maxWeight'] as num).toDouble(),
  fee: (json['fee'] as num).toDouble(),
);

Map<String, dynamic> _$DeliveryRuleToJson(DeliveryRule instance) =>
    <String, dynamic>{'maxWeight': instance.maxWeight, 'fee': instance.fee};
