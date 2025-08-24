import 'package:sudan_goods/follow/domain/entities/store_summary.dart';

abstract class StoreRepo {
  Future<StoreSummary?> getSummary(String storeId);
}
