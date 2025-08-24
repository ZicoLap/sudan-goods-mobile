import 'dart:async';

import 'package:sudan_goods/follow/domain/repositories/follow_repo.dart';

class IsFollowing {
  final FollowRepo _repo;
  IsFollowing(this._repo);

  Stream<bool> call({required String uid, required String storeId}) {
    return _repo.isFollowing(uid: uid, storeId: storeId);
  }
}
