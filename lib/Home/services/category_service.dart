import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/store/category_model.dart';

class CategoryService {
  final _categoryRef = FirebaseFirestore.instance.collection('categories');

 Future<List<Category>> fetchActiveCategories() async {
 

  try {
    final querySnapshot = await _categoryRef
        .where('isActive', isEqualTo: true)
        .get();

    final List<Category> categories = [];

    for (final doc in querySnapshot.docs) {
      final data = doc.data();

      try {
        final category = Category.fromJson(data);
        categories.add(category);
      } catch (e) {
        print('❌ Failed to parse category document: ${doc.id}');
        print('🔍 Raw data: $data');
        print('⚠️ Error: $e');
      }
    }

    return categories;
  } catch (e) {
    print('Error fetching categories: $e');
    rethrow;
  }
}

}
