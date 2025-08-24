import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sudan_goods/follow/domain/entities/store_summary.dart';
import 'package:sudan_goods/follow/domain/usecases/follow_store.dart';
import 'package:sudan_goods/follow/domain/usecases/get_following_list.dart';
import 'package:sudan_goods/follow/domain/usecases/is_following.dart';
import 'package:sudan_goods/follow/domain/usecases/unfollow_store.dart';

/// High-level controller to integrate Follow/Unfollow into UI without
/// coupling UI to Firebase. Keeps optimistic state and exposes streams.
class FollowController extends ChangeNotifier {
  FollowController({
    required String uid,
    required FollowStore followStore,
    required UnfollowStore unfollowStore,
    required IsFollowing isFollowing,
    required GetFollowingList getFollowingList,
  })  : _uid = uid,
        _followStore = followStore,
        _unfollowStore = unfollowStore,
        _isFollowing = isFollowing,
        _getFollowingList = getFollowingList;

  final String _uid;
  final FollowStore _followStore;
  final UnfollowStore _unfollowStore;
  final IsFollowing _isFollowing;
  final GetFollowingList _getFollowingList;

  final Map<String, bool> _lastFollowing = {};
  final Map<String, StreamSubscription<bool>> _subs = {};
  final Map<String, StreamController<bool>> _controllers = {};

  String? lastError;

  /// Returns the last known following state for a store if cached.
  bool? getCachedFollowing(String storeId) => _lastFollowing[storeId];

  /// Watch the following state for a store as a stream that also reflects
  /// optimistic updates performed via [toggleFollow].
  Stream<bool> watchIsFollowing(String storeId) {
    if (_controllers.containsKey(storeId)) {
      return _controllers[storeId]!.stream;
    }

    // Create a broadcast controller that starts/stops the underlying subscription
    // based on listeners, and emits cached state on first listen.
    late final StreamController<bool> ctrl;
    ctrl = StreamController<bool>.broadcast(
      onListen: () {
        final cached = _lastFollowing[storeId];
        if (cached != null) {
          ctrl.add(cached);
        }
        // Start underlying subscription only once (on first listener)
        if (!_subs.containsKey(storeId)) {
          final sub = _isFollowing(uid: _uid, storeId: storeId).listen((value) {
            _lastFollowing[storeId] = value;
            ctrl.add(value);
          }, onError: (e, st) {
            lastError = e.toString();
            notifyListeners();
          });
          _subs[storeId] = sub;
        }
      },
      onCancel: () {
        // Only when last listener detaches, clean up.
        if (!ctrl.hasListener) {
          _subs.remove(storeId)?.cancel();
          final removed = _controllers.remove(storeId);
          if (removed == ctrl) {
            ctrl.close();
          }
        }
      },
    );
    _controllers[storeId] = ctrl;

    return ctrl.stream;
  }

  /// Toggle follow with optimistic UI update. If the write fails, reverts
  /// and exposes an error via [lastError].
  Future<void> toggleFollow(String storeId, {StoreSummary? knownSummary}) async {
    // Ensure we have at least one watcher so UI can see optimistic state.
    watchIsFollowing(storeId);
    // Read current from cache if present; default to false to avoid initial wait.
    final current = _lastFollowing[storeId] ?? false;

    final optimistic = !current;
    _lastFollowing[storeId] = optimistic;
    _controllers[storeId]?.add(optimistic);

    try {
      if (optimistic) {
        await _followStore(uid: _uid, storeId: storeId, summary: knownSummary);
      } else {
        await _unfollowStore(uid: _uid, storeId: storeId);
      }
    } catch (e) {
      // Revert on failure
      _lastFollowing[storeId] = current;
      _controllers[storeId]?.add(current);
      lastError = e.toString();
      notifyListeners();
    }
  }

  /// Paginated stream for My Followed Stores list.
  /// The UI can call this for page-1, then again with [startAfterStoreId]
  /// as the last item id of the previous page for infinite scroll.
  Stream<List<StoreSummary>> getFollowingPage({
    required int limit,
    String? startAfterStoreId,
  }) {
    return _getFollowingList(
      uid: _uid,
      limit: limit,
      startAfterStoreId: startAfterStoreId,
    );
  }

  @override
  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    for (final c in _controllers.values) {
      c.close();
    }
    super.dispose();
  }
}
