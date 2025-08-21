

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// JsonConverter that maps Firestore [Timestamp] values from/to JSON.
///
/// Accepts either a native [Timestamp] instance or a Map with
/// `_seconds` and `_nanoseconds` keys (as sometimes produced by
/// serialization pipelines).
class TimestampConverter implements JsonConverter<Timestamp, Object?> {
  const TimestampConverter();

  /// Converts a JSON value to a Firestore [Timestamp].
  ///
  /// Throws an [Exception] if the provided [json] cannot be interpreted
  /// as a [Timestamp] or a map containing the `_seconds` and
  /// `_nanoseconds` fields.
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

  /// Converts a Firestore [Timestamp] to a JSON-serializable value.
  @override
  Object? toJson(Timestamp object) => object;
}
