// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: strict-raw-types
// ignore_for_file: argument_type_not_assignable

// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:sentimento_app/backend/table.dart';
import 'package:sentimento_app/core/lat_lng.dart';

// Project imports:

abstract class SupabaseDataRow {
  SupabaseDataRow(this.data);

  SupabaseTable get table;
  Map<String, dynamic> data;

  String get tableName => table.tableName;

  T? getField<T>(final String fieldName, [final T? defaultValue]) =>
      _supaDeserialize<T>(data[fieldName]) ?? defaultValue;
  void setField<T>(final String fieldName, final T? value) =>
      data[fieldName] = supaSerialize<T>(value);
  List<T> getListField<T>(final String fieldName) =>
      _supaDeserializeList<T>(data[fieldName]) ?? [];
  void setListField<T>(final String fieldName, final List<T>? value) =>
      data[fieldName] = supaSerializeList<T>(value);

  @override
  String toString() =>
      '''
Table: $tableName
Row Data: {${data.isNotEmpty ? '\n' : ''}${data.entries.map((final e) => '  (${e.value.runtimeType}) "${e.key}": ${e.value},\n').join('')}}''';

  @override
  int get hashCode => Object.hash(
    tableName,
    Object.hashAllUnordered(
      data.entries.map((final e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  bool operator ==(final Object other) =>
      other is SupabaseDataRow && mapEquals(other.data, data);
}

dynamic supaSerialize<T>(final T? value) {
  if (value == null) {
    return null;
  }

  switch (T) {
    case DateTime:
      return (value as DateTime).toIso8601String();
    case PostgresTime:
      return (value as PostgresTime).toIso8601String();
    case LatLng:
      final latLng = (value as LatLng);
      return {'lat': latLng.latitude, 'lng': latLng.longitude};
    default:
      return value;
  }
}

List<dynamic>? supaSerializeList<T>(final List<T>? value) =>
    value?.map((final v) => supaSerialize<T>(v)).toList();

T? _supaDeserialize<T>(final dynamic value) {
  if (value == null) {
    return null;
  }

  switch (T) {
    case int:
      return (value as num).round() as T?;
    case double:
      return (value as num).toDouble() as T?;
    case DateTime:
      return DateTime.tryParse(value as String)?.toLocal() as T?;
    case PostgresTime:
      return PostgresTime.tryParse(value as String) as T?;
    case LatLng:
      final latLng = value is Map ? value : json.decode(value) as Map;
      final lat = latLng['lat'] ?? latLng['latitude'];
      final lng = latLng['lng'] ?? latLng['longitude'];
      return lat is num && lng is num
          ? LatLng(lat.toDouble(), lng.toDouble()) as T?
          : null;
    default:
      return value as T;
  }
}

List<T>? _supaDeserializeList<T>(final dynamic value) => value is List
    ? value
          .map((final v) => _supaDeserialize<T>(v))
          .where((final v) => v != null)
          .map((final v) => v as T)
          .toList()
    : null;
