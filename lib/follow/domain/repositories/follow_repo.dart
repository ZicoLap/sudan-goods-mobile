import 'dart:async';

import '../entities/store_summary.dart';

abstract class FollowRepo {
  Future<void> follow({required String uid, required StoreSummary store});
  Future<void> unfollow({required String uid, required String storeId});

  Stream<bool> isFollowing({required String uid, required String storeId});

  /// Paginated stream of followed store summaries.
  /// - ordered by followedAt desc
  /// - limit: page size
  /// - startAfterStoreId: optional cursor (document id to start after)
  Stream<List<StoreSummary>> getFollowing({
    required String uid,
    required int limit,
    String? startAfterStoreId,
  });
}
