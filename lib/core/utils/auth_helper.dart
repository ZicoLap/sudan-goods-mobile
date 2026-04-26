import 'package:firebase_auth/firebase_auth.dart';

Future<bool> isCurrentUserAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  final token = await user.getIdTokenResult();
  return token.claims?['role'] == 'admin';
}
