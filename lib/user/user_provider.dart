// ✅ lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/user/user_model.dart';

class UserProvider with ChangeNotifier {
  AppUser? _currentUser;
  final _firestore = FirebaseFirestore.instance;

  AppUser get currentUser {
    if (_currentUser == null) {
      throw Exception('User not loaded. Call fetchUser(uid) first.');
    }
    return _currentUser!;
  }

  bool get isUserLoaded => _currentUser != null;

  Future<void> fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User not found in Firestore');
    }

    _currentUser = AppUser.fromJson(doc.data()!);
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_currentUser != null) {
      await fetchUser(_currentUser!.uid);
    }
  }

  void updateUser(AppUser updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
