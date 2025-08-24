import 'package:sudan_goods/follow/domain/entities/store_summary.dart';
import 'package:sudan_goods/follow/domain/repositories/follow_repo.dart';

class GetFollowingList {
  final FollowRepo _repo;
  GetFollowingList(this._repo);

  Stream<List<StoreSummary>> call({
    required String uid,
    required int limit,
    String? startAfterStoreId,
  }) {
    return _repo.getFollowing(
      uid: uid,
      limit: limit,
      startAfterStoreId: startAfterStoreId,
    );
  }
}
