// lib/models/shared_models/timestamp_converter.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// JsonConverter that maps Firestore Timestamp/ISO strings to DateTime? and back.
///
/// This converter is defensive and accepts:
/// - Firestore [Timestamp]
/// - Map-like serialized timestamps with `_seconds` and `_nanoseconds`
/// - ISO 8601 formatted strings
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  /// Const constructor for use in annotations.
  const TimestampConverter();

  /// Converts Firestore/serialized timestamp values to [DateTime?].
  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    // Handle Map-like serialized timestamps (defensive)
    if (json is Map && json['_seconds'] != null) {
      return Timestamp(
        json['_seconds'] as int,
        (json['_nanoseconds'] ?? 0) as int,
      ).toDate();
    }
    // Fallback for ISO 8601 string (your existing data)
    return DateTime.tryParse(json.toString());
  }

  /// Converts [DateTime?] to a Firestore [Timestamp] or null.
  @override
  Object? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}
