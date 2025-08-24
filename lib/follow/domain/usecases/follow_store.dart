import 'dart:async';

import 'package:sudan_goods/follow/domain/entities/store_summary.dart';
import 'package:sudan_goods/follow/domain/gateways/notifications_gateway.dart';
import 'package:sudan_goods/follow/domain/repositories/follow_repo.dart';
import 'package:sudan_goods/follow/domain/repositories/store_repo.dart';

class FollowStore {
  final FollowRepo _followRepo;
  final StoreRepo _storeRepo;
  final NotificationsGateway? _notifications;

  FollowStore(this._followRepo, this._storeRepo, {NotificationsGateway? notifications})
      : _notifications = notifications;

  Future<void> call({required String uid, required String storeId, StoreSummary? summary}) async {
    // Avoid duplicate writes if already following
    final already = await _followRepo
        .isFollowing(uid: uid, storeId: storeId)
        .first;
    if (already) return;

    final resolved = summary ?? await _storeRepo.getSummary(storeId);
    if (resolved == null) {
      throw StateError('Store not found: $storeId');
    }

    await _followRepo.follow(uid: uid, store: resolved);

    // Future hook: subscribe to FCM topic "store_{storeId}"
    if (_notifications != null) {
      await _notifications.subscribeToStore(storeId);
    }
  }
}
