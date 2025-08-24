import '../../domain/entities/store_summary.dart';

/// Mapper between Firestore maps and [StoreSummary].
class StoreSummaryDto {
  static StoreSummary fromMap(Map<String, dynamic> data) {
    return StoreSummary(
      id: (data['storeId'] ?? data['id']).toString(),
      name: (data['storeName'] ?? data['name'] ?? '').toString(),
      logoUrl: data['storeLogoUrl'] as String?,
      isActive: (data['storeIsActive'] ?? data['isActive'] ?? true) as bool,
      isApproved: (data['storeIsApproved'] ?? data['isApproved'] ?? false) as bool,
    );
  }

  static Map<String, dynamic> toMap(StoreSummary s) {
    return <String, dynamic>{
      'storeId': s.id,
      'storeName': s.name,
      'storeLogoUrl': s.logoUrl,
      'storeIsActive': s.isActive,
      'storeIsApproved': s.isApproved,
    };
  }
}
