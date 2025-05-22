import 'package:sudan_goods/models/store/store_model.dart';

double calculateDeliveryFee({
  required Store store,
  required double totalWeight,
  required double subtotal,
}) {
  // ✅ Free delivery if subtotal passes threshold
  if (store.freeDeliveryOver != null && subtotal >= store.freeDeliveryOver!) {
    return 0.0;
  }

  // ✅ Check deliveryPricing rules
  for (final rule in store.deliveryPricing) {
    if (totalWeight <= rule.maxWeight) {
      return rule.fee;
    }
  }

  // 🟡 Fallback: return last fee (highest tier)
  return store.deliveryPricing.isNotEmpty
      ? store.deliveryPricing.last.fee
      : 0.0; // if no pricing set, free by default
}
