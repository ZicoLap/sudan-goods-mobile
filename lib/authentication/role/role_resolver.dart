import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Resolves the application role for an authenticated user.
///
/// Uses Firebase Auth custom claims first (fast path), then falls back to a
/// single Firestore document read for legacy users whose claims are not set.
class RoleResolver {
  final FirebaseFirestore _firestore;

  RoleResolver({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Resolves the role for the given [user].
  ///
  /// Returns the role string, or `null` if the user document exists but has
  /// no role (indicates incomplete registration / Cloud Function lag).
  Future<String?> resolve(User user) async {
    try {
      final tokenResult = await user.getIdTokenResult(true);
      final role = tokenResult.claims?['role'];
      if (role is String && role.isNotEmpty) {
        return role;
      }
    } catch (_) {
      // Fall through to Firestore lookup.
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data();
    final role = data?['role'];
    if (role is String && role.isNotEmpty) {
      return role;
    }

    // Document exists but role is missing; registration may still be processing.
    return null;
  }
}
