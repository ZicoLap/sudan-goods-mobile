import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(dynamic timestamp) {
  if (timestamp == null) return '';
  final date =
      (timestamp is Timestamp)
          ? timestamp.toDate()
          : DateTime.tryParse(timestamp.toString());
  if (date == null) return '';
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
