import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageService {
  // Pick image from device
  Future<Uint8List?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first.bytes;
    }
    return null; // user canceled
  }


 Future<String> uploadImage(Uint8List file, String path) async {
  final ref = FirebaseStorage.instance.ref().child(path);
  final uploadTask = ref.putData(file);
  final snapshot = await uploadTask;
  final downloadUrl = await snapshot.ref.getDownloadURL(); // ✅ important line
  return downloadUrl;
}

}
