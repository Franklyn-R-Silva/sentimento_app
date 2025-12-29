// ignore_for_file: strict-raw-types
// ignore_for_file: argument_type_not_assignable

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/backend/database.dart';

abstract class SupabaseTable<T extends SupabaseDataRow> {
  final logger = Logger();
  String get tableName;
  T createRow(final Map<String, dynamic> data);

  PostgrestFilterBuilder _select() => SupaFlow.client.from(tableName).select();

  Future<List<T>> queryRows({
    required final PostgrestTransformBuilder Function(PostgrestFilterBuilder)
    queryFn,
    final int? limit,
  }) {
    final select = _select();
    var query = queryFn(select);
    query = limit != null ? query.limit(limit) : query;
    return query.select().then((final rows) => rows.map(createRow).toList());
  }

  Future<List<T>> querySingleRow({
    required final PostgrestTransformBuilder Function(PostgrestFilterBuilder)
    queryFn,
  }) => queryFn(_select())
      .limit(1)
      .maybeSingle()
      .catchError((final e) => logger.e('Error querying row: $e'))
      .then((final r) => [if (r != null) createRow(r)]);

  Future<T> insert(final Map<String, dynamic> data) => SupaFlow.client
      .from(tableName)
      .insert(data)
      .select()
      .limit(1)
      .single()
      .then(createRow);

  Future<List<T>> update({
    required final Map<String, dynamic> data,
    required final PostgrestTransformBuilder Function(PostgrestFilterBuilder)
    matchingRows,
    final bool returnRows = false,
  }) async {
    final update = matchingRows(SupaFlow.client.from(tableName).update(data));
    if (!returnRows) {
      await update;
      return [];
    }
    return update.select().then((final rows) => rows.map(createRow).toList());
  }

  Future<List<T>> delete({
    required final PostgrestTransformBuilder Function(PostgrestFilterBuilder)
    matchingRows,
    final bool returnRows = false,
  }) async {
    final delete = matchingRows(SupaFlow.client.from(tableName).delete());
    if (!returnRows) {
      await delete;
      return [];
    }
    return delete.select().then((final rows) => rows.map(createRow).toList());
  }
}

extension NullSafePostgrestFilters on PostgrestFilterBuilder {
  PostgrestFilterBuilder eqOrNull(final String column, final dynamic value) {
    return value != null ? eq(column, value) : this;
  }

  PostgrestFilterBuilder neqOrNull(final String column, final dynamic value) {
    return value != null ? neq(column, value) : this;
  }

  PostgrestFilterBuilder ltOrNull(final String column, final dynamic value) {
    return value != null ? lt(column, value) : this;
  }

  PostgrestFilterBuilder lteOrNull(final String column, final dynamic value) {
    return value != null ? lte(column, value) : this;
  }

  PostgrestFilterBuilder gtOrNull(final String column, final dynamic value) {
    return value != null ? gt(column, value) : this;
  }

  PostgrestFilterBuilder gteOrNull(final String column, final dynamic value) {
    return value != null ? gte(column, value) : this;
  }

  PostgrestFilterBuilder containsOrNull(
    final String column,
    final dynamic value,
  ) {
    return value != null ? contains(column, value) : this;
  }

  PostgrestFilterBuilder overlapsOrNull(
    final String column,
    final dynamic value,
  ) {
    return value != null ? overlaps(column, value) : this;
  }

  PostgrestFilterBuilder inFilterOrNull(
    final String column,
    final List<dynamic>? values,
  ) {
    return values != null ? inFilter(column, values) : this;
  }
}

extension NullSafeSupabaseStreamFilters on SupabaseStreamFilterBuilder {
  SupabaseStreamBuilder eqOrNull(final String column, final dynamic value) {
    return value != null ? eq(column, value) : this;
  }

  SupabaseStreamBuilder neqOrNull(final String column, final dynamic value) {
    return value != null ? neq(column, value) : this;
  }

  SupabaseStreamBuilder ltOrNull(final String column, final dynamic value) {
    return value != null ? lt(column, value) : this;
  }

  SupabaseStreamBuilder lteOrNull(final String column, final dynamic value) {
    return value != null ? lte(column, value) : this;
  }

  SupabaseStreamBuilder gtOrNull(final String column, final dynamic value) {
    return value != null ? gt(column, value) : this;
  }

  SupabaseStreamBuilder gteOrNull(final String column, final dynamic value) {
    return value != null ? gte(column, value) : this;
  }

  SupabaseStreamBuilder inFilterOrNull(
    final String column,
    final List<Object>? values,
  ) {
    return values != null ? inFilter(column, values) : this;
  }
}

class PostgresTime {
  PostgresTime(this.time);
  DateTime? time;

  static PostgresTime? tryParse(final String formattedString) {
    final datePrefix = DateTime.now().toIso8601String().split('T').first;
    return PostgresTime(
      DateTime.tryParse('${datePrefix}T$formattedString')?.toLocal(),
    );
  }

  String? toIso8601String() {
    return time?.toIso8601String().split('T').last;
  }

  @override
  String toString() {
    return toIso8601String() ?? '';
  }
}
