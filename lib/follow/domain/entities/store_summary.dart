import 'package:sudan_goods/models/store/store_model.dart';

/// Minimal denormalized store summary stored inside
/// `/users/{uid}/following/{storeId}` for fast list rendering.
class StoreSummary {
  final String id;
  final String name;
  final String? logoUrl;
  final bool isActive;

  const StoreSummary({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.isActive,
  });

  factory StoreSummary.fromStore(Store s) => StoreSummary(
        id: s.id,
        name: s.name,
        logoUrl: s.logoThumbUrl ?? s.logoUrl,
        isActive: s.isActive,
      );

  factory StoreSummary.fromMap(String id, Map<String, dynamic> data) => StoreSummary(
        id: id,
        name: (data['storeName'] as String?) ?? '',
        logoUrl: data['storeLogoUrl'] as String?,
        isActive: (data['storeIsActive'] as bool?) ?? true,
      );

  Map<String, dynamic> toFollowingDocMap() => {
        'storeId': id,
        'storeName': name,
        'storeLogoUrl': logoUrl,
        'storeIsActive': isActive,
        // 'followedAt' will be set with server timestamp on write
      };
}
