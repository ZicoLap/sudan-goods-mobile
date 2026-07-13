import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized, injectable account operations backed by FirebaseAuth.
///
/// Provides helpers for logout, delete account, change email, and change password.
class AccountService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AccountService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : auth = auth ?? FirebaseAuth.instance,
      firestore = firestore ?? FirebaseFirestore.instance;

  /// The default singleton instance used by the application.
  ///
  /// Tests can override this value to inject mocks:
  /// `AccountService.instance = AccountService(auth: mockAuth, firestore: mockFirestore);`
  static AccountService instance = AccountService();

  /// Signs out the current user.
  Future<void> logout() async {
    await auth.signOut();
  }

  /// Deletes the currently authenticated user's account.
  ///
  /// Note: May throw [FirebaseAuthException] with code 'requires-recent-login'.
  /// The UI should handle re-authentication in that case before retrying.
  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.delete();
  }

  /// Updates the authenticated user's email address.
  ///
  /// If [verifyBefore] is true, a verification link is sent to [newEmail] and the
  /// actual email change will only take effect after the user completes the
  /// verification flow. In that case, this method will NOT update Firestore.
  ///
  /// If [verifyBefore] is false (default), updates the email immediately and, if
  /// [syncFirestore] is true, also updates `users/{uid}.email` in Firestore.
  ///
  /// May throw [FirebaseAuthException] with code 'requires-recent-login'. The UI
  /// should handle re-authentication (see
  /// [reauthenticateWithEmailAndPassword]) before retrying.
  Future<void> changeEmail(
    String newEmail, {
    bool verifyBefore = false,
    bool syncFirestore = true,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }

    if (verifyBefore) {
      // Sends a verification email; actual change happens once verified.
      await user.verifyBeforeUpdateEmail(newEmail);
      return;
    }

    // ignore: deprecated_member_use
    await user.updateEmail(newEmail);

    if (syncFirestore) {
      await firestore.collection('users').doc(user.uid).update({'email': newEmail});
    }

    await user.reload();
  }

  /// Updates the authenticated user's password.
  /// May require recent login depending on Firebase rules.
  Future<void> changePassword(String newPassword) async {
    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.updatePassword(newPassword);
  }

  /// Returns the currently authenticated [User], if any.
  User? get currentUser => auth.currentUser;

  /// Forces a reload of the FirebaseAuth user from the server.
  Future<void> reloadUser() async {
    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.reload();
  }

  /// Sends an email verification to the current user.
  Future<void> sendEmailVerification() async {
    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    await user.sendEmailVerification();
  }

  /// Returns whether the current user's email is verified.
  bool get isEmailVerified => auth.currentUser?.emailVerified ?? false;

  /// Re-authenticates the current user with email/password credentials.
  ///
  /// Useful before sensitive operations like changing email/password or deleting the account
  /// when Firebase throws [FirebaseAuthException] with code 'requires-recent-login'.
  Future<UserCredential> reauthenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final user = auth.currentUser;
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
  Future<void> sendPasswordResetEmail(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  /// Updates the current user's display name in FirebaseAuth profile.
  /// Note: App profile fields are stored in Firestore; this only affects FirebaseAuth.
  Future<void> updateDisplayName(String displayName) async {
    final user = auth.currentUser;
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
  Future<void> updatePhotoURL(String photoURL) async {
    final user = auth.currentUser;
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
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    final token = await user.getIdToken(forceRefresh);
    return token;
  }

  /// Synchronizes the email field in Firestore with the current FirebaseAuth user's email.
  /// Useful after completing a verify-before-update flow.
  Future<void> syncEmailToFirestore() async {
    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user',
      );
    }
    final email = user.email;
    if (email == null) return;
    await firestore.collection('users').doc(user.uid).update({'email': email});
  }
}
