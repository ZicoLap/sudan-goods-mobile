import 'package:json_annotation/json_annotation.dart';

part 'delivery_rules_model.g.dart';

@JsonSerializable()
class DeliveryRule {
  final double maxWeight;
  final double fee;

  DeliveryRule({required this.maxWeight, required this.fee});

  factory DeliveryRule.fromJson(Map<String, dynamic> json) => _$DeliveryRuleFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryRuleToJson(this);
}
