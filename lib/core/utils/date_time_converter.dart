import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// JsonConverter for Firestore [Timestamp] to/from Dart [DateTime].
///
/// Apply this converter on `@JsonSerializable` models to seamlessly serialize
/// and deserialize `DateTime` fields stored as Firestore `Timestamp`.
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  /// Converts a Firestore [Timestamp] into a Dart [DateTime].
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  /// Converts a Dart [DateTime] into a Firestore [Timestamp].
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}


/* 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<Timestamp, Object?> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Object? json) {
    if (json is Timestamp) return json;
    if (json is Map) {
      return Timestamp(
        (json['_seconds'] as int),
        (json['_nanoseconds'] as int),
      );
    }
    throw Exception('Invalid timestamp data');
  }

  @override
  Object? toJson(Timestamp object) => object;
}
 */