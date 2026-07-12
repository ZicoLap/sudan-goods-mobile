import '../entities/store_summary.dart';

/// Abstract store repository for search and lookup used by messaging.
abstract class StoreRepo {
  Future<List<StoreSummary>> searchStores(String query, {int limit = 20});
  Future<StoreSummary?> getStoreSummary(String storeId);
}
