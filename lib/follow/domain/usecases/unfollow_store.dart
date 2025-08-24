import 'package:sudan_goods/follow/domain/gateways/notifications_gateway.dart';
import 'package:sudan_goods/follow/domain/repositories/follow_repo.dart';

class UnfollowStore {
  final FollowRepo _followRepo;
  final NotificationsGateway? _notifications;

  UnfollowStore(this._followRepo, {NotificationsGateway? notifications})
      : _notifications = notifications;

  Future<void> call({required String uid, required String storeId}) async {
    await _followRepo.unfollow(uid: uid, storeId: storeId);
    if (_notifications != null) {
      await _notifications.unsubscribeFromStore(storeId);
    }
  }
}
