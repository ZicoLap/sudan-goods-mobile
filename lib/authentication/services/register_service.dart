import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/user/user_model.dart';

class RegisterService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User> createUser(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  Future<void> saveUserToFirestore(AppUser appUser) async {
    await _firestore.collection('users').doc(appUser.uid).set(appUser.toJson());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
