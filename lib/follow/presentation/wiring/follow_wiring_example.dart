// Example wiring only. Not used by the app unless you import it.
// Demonstrates how to construct FollowController with Provider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/follow/data/firestore/firestore_follow_repository.dart';
import 'package:sudan_goods/follow/data/firestore/firestore_store_repository.dart';
import 'package:sudan_goods/follow/domain/gateways/notifications_gateway.dart';
import 'package:sudan_goods/follow/domain/usecases/follow_store.dart';
import 'package:sudan_goods/follow/domain/usecases/get_following_list.dart';
import 'package:sudan_goods/follow/domain/usecases/is_following.dart';
import 'package:sudan_goods/follow/domain/usecases/unfollow_store.dart';
import 'package:sudan_goods/follow/presentation/controllers/follow_controller.dart';

class NoopNotificationsGateway implements NotificationsGateway {
  @override
  Future<void> subscribeToStore(String storeId) async {}
  @override
  Future<void> unsubscribeFromStore(String storeId) async {}
}

/// Factory to create a FollowController for a given uid.
FollowController makeFollowControllerForUid(String uid) {
  final followRepo = FirestoreFollowRepository();
  final storeRepo = FirestoreStoreRepository();
  final notifications = NoopNotificationsGateway(); // swap later for real FCM

  final followUC = FollowStore(followRepo, storeRepo, notifications: notifications);
  final unfollowUC = UnfollowStore(followRepo, notifications: notifications);
  final isFollowingUC = IsFollowing(followRepo);
  final getFollowingUC = GetFollowingList(followRepo);

  return FollowController(
    uid: uid,
    followStore: followUC,
    unfollowStore: unfollowUC,
    isFollowing: isFollowingUC,
    getFollowingList: getFollowingUC,
  );
}

/// Provider setup example:
///
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(
///       create: (_) => makeFollowControllerForUid(currentUserId),
///     ),
///   ],
///   child: ...,
/// )
///
/// Minimal button adapter example:
class FollowButtonAdapter extends StatelessWidget {
  final String storeId;
  final Widget Function(bool isFollowing, VoidCallback onTap) builder;

  const FollowButtonAdapter({super.key, required this.storeId, required this.builder});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FollowController>(context, listen: false);
    return StreamBuilder<bool>(
      stream: controller.watchIsFollowing(storeId),
      initialData: false,
      builder: (context, snap) {
        final isFollowing = snap.data ?? false;
        return builder(isFollowing, () {
          controller.toggleFollow(storeId);
        });
      },
    );
  }
}
