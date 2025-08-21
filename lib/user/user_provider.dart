// ✅ lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/user/user_model.dart';

 /// Provider that manages the authenticated user's profile state.
 ///
 /// Exposes helpers to fetch, refresh, update, and clear the current user
 /// backed by Firestore. Widgets can listen to this provider for changes.
 class UserProvider with ChangeNotifier {
  AppUser? _currentUser;
  final _firestore = FirebaseFirestore.instance;

  /// Returns the currently loaded [AppUser].
  ///
  /// Throws if the user has not been fetched yet. Call `fetchUser(uid)` first
  /// or use [isUserLoaded] to guard access.
  AppUser get currentUser {
    if (_currentUser == null) {
      throw Exception('User not loaded. Call fetchUser(uid) first.');
    }
    return _currentUser!;
  }

  /// Whether the user has been fetched and is available in memory.
  bool get isUserLoaded => _currentUser != null;

  /// Loads the user document identified by [uid] from Firestore and updates
  /// local state, notifying listeners on success.
  Future<void> fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User not found in Firestore');
    }

    _currentUser = AppUser.fromJson(doc.data()!);
    notifyListeners();
  }

  /// Clears the current user from memory and notifies listeners.
  void clear() {
    _currentUser = null;
    notifyListeners();
  }

  /// Re-fetches the current user from Firestore if a user is loaded.
  /// No-op if no user is set.
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      await fetchUser(_currentUser!.uid);
    }
  }

  /// Updates the in-memory user model and notifies listeners.
  ///
  /// Note: This does not write back to Firestore; callers must handle
  /// persistence if needed.
  void updateUser(AppUser updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
