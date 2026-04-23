import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/authentication/user/user_model.dart';

/// ⚠️ DEPRECATED: DO NOT USE FOR NEW REGISTRATIONS
///
/// This service performs client-side registration which is insecure.
/// Use [ServerRegisterService] instead which calls the secure Cloud Function.
///
/// Keeping for potential legacy migration utilities only.
@Deprecated('Use ServerRegisterService for all new registrations')
class RegisterService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @Deprecated('Use ServerRegisterService.registerUser() instead')
  Future<User> createUser(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  @Deprecated('Email verification is handled by the server')
  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  @Deprecated('Firestore writes should only happen through Cloud Functions')
  Future<void> saveUserToFirestore(AppUser appUser) async {
    await _firestore.collection('users').doc(appUser.uid).set(appUser.toJson());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
