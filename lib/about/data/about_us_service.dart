import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/about_us_content.dart';

class AboutUsService {
  final FirebaseFirestore _db;

  AboutUsService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<AboutUsContent?> fetch() async {
    final doc = await _db.collection('app_content').doc('about_us').get();
    if (!doc.exists || doc.data() == null) return null;
    return AboutUsContent.fromMap(doc.data()!);
  }
}
