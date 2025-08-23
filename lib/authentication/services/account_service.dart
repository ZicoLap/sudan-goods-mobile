import 'package:firebase_auth/firebase_auth.dart';

/// Centralized account operations backed by FirebaseAuth.
///
/// Provides helpers for logout, delete account, change email, and change password.
class AccountService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs out the current user.
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Deletes the currently authenticated user's account.
  ///
  /// Note: May throw [FirebaseAuthException] with code 'requires-recent-login'.
  /// The UI should handle re-authentication in that case before retrying.
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.delete();
  }

  /// Updates the authenticated user's email address.
  /// May require recent login depending on Firebase rules.
  static Future<void> changeEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.updateEmail(newEmail);
  }

  /// Updates the authenticated user's password.
  /// May require recent login depending on Firebase rules.
  static Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.updatePassword(newPassword);
  }

  /// Returns the currently authenticated [User], if any.
  static User? get currentUser => _auth.currentUser;

  /// Forces a reload of the FirebaseAuth user from the server.
  static Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.reload();
  }

  /// Sends an email verification to the current user.
  static Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.sendEmailVerification();
  }

  /// Returns whether the current user's email is verified.
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Re-authenticates the current user with email/password credentials.
  ///
  /// Useful before sensitive operations like changing email/password or deleting the account
  /// when Firebase throws [FirebaseAuthException] with code 'requires-recent-login'.
  static Future<UserCredential> reauthenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    final cred = EmailAuthProvider.credential(email: email, password: password);
    return await user.reauthenticateWithCredential(cred);
  }

  /// Sends a password reset email to the specified [email].
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Updates the current user's display name in FirebaseAuth profile.
  /// Note: App profile fields are stored in Firestore; this only affects FirebaseAuth.
  static Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.updateDisplayName(displayName);
  }

  /// Updates the current user's photo URL in FirebaseAuth profile.
  /// Note: App profile fields are stored in Firestore; this only affects FirebaseAuth.
  static Future<void> updatePhotoURL(String photoURL) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.updatePhotoURL(photoURL);
  }

  /// Retrieves the ID token for the current user.
  /// May return null depending on FirebaseAuth SDK version/state.
  static Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    final token = await user.getIdToken(forceRefresh);
    return token;
  }
}
