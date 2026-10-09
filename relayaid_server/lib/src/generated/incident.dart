/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import 'incident_severity.dart' as _ifp7jacs;
import 'incident_status.dart' as _ikduxsi0;
import 'incident_type.dart' as _i3tf8ajh;

abstract class Incident
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Incident._({
    this.id,
    required this.organizationId,
    required this.type,
    required this.severity,
    required this.status,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    required this.peopleAffected,
    required this.reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    this.escalationDueAt,
    this.escalatedAt,
  }) : reportedAt = reportedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Incident({
    _is.UuidValue? id,
    required _is.UuidValue organizationId,
    required _i3tf8ajh.IncidentType type,
    required _ifp7jacs.IncidentSeverity severity,
    required _ikduxsi0.IncidentStatus status,
    required String title,
    required String description,
    double? latitude,
    double? longitude,
    required int peopleAffected,
    required _is.UuidValue reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    DateTime? escalationDueAt,
    DateTime? escalatedAt,
  }) = _IncidentImpl;

  factory Incident.fromJson(Map<String, dynamic> jsonSerialization) {
    return Incident(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      organizationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      type: _i3tf8ajh.IncidentType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      severity: _ifp7jacs.IncidentSeverity.fromJson(
        (jsonSerialization['severity'] as String),
      ),
      status: _ikduxsi0.IncidentStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      peopleAffected: jsonSerialization['peopleAffected'] as int,
      reportedBy: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['reportedBy'],
      ),
      reportedAt: jsonSerialization['reportedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['reportedAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      escalationDueAt: jsonSerialization['escalationDueAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['escalationDueAt'],
            ),
      escalatedAt: jsonSerialization['escalatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['escalatedAt'],
            ),
    );
  }

  static final t = IncidentTable();

  static const db = IncidentRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue organizationId;

  _i3tf8ajh.IncidentType type;

  _ifp7jacs.IncidentSeverity severity;

  _ikduxsi0.IncidentStatus status;

  String title;

  String description;

  double? latitude;

  double? longitude;

  int peopleAffected;

  _is.UuidValue reportedBy;

  DateTime reportedAt;

  DateTime updatedAt;

  DateTime? escalationDueAt;

  DateTime? escalatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Incident]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Incident copyWith({
    _is.UuidValue? id,
    _is.UuidValue? organizationId,
    _i3tf8ajh.IncidentType? type,
    _ifp7jacs.IncidentSeverity? severity,
    _ikduxsi0.IncidentStatus? status,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    int? peopleAffected,
    _is.UuidValue? reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    DateTime? escalationDueAt,
    DateTime? escalatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Incident',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'type': type.toJson(),
      'severity': severity.toJson(),
      'status': status.toJson(),
      'title': title,
      'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'peopleAffected': peopleAffected,
      'reportedBy': reportedBy.toJson(),
      'reportedAt': reportedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (escalationDueAt != null) 'escalationDueAt': escalationDueAt?.toJson(),
      if (escalatedAt != null) 'escalatedAt': escalatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Incident',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'type': type.toJson(),
      'severity': severity.toJson(),
      'status': status.toJson(),
      'title': title,
      'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'peopleAffected': peopleAffected,
      'reportedBy': reportedBy.toJson(),
      'reportedAt': reportedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (escalationDueAt != null) 'escalationDueAt': escalationDueAt?.toJson(),
      if (escalatedAt != null) 'escalatedAt': escalatedAt?.toJson(),
    };
  }

  static IncidentInclude include() {
    return IncidentInclude._();
  }

  static IncidentIncludeList includeList({
    _is.WhereExpressionBuilder<IncidentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    IncidentInclude? include,
  }) {
    return IncidentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentImpl extends Incident {
  _IncidentImpl({
    _is.UuidValue? id,
    required _is.UuidValue organizationId,
    required _i3tf8ajh.IncidentType type,
    required _ifp7jacs.IncidentSeverity severity,
    required _ikduxsi0.IncidentStatus status,
    required String title,
    required String description,
    double? latitude,
    double? longitude,
    required int peopleAffected,
    required _is.UuidValue reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    DateTime? escalationDueAt,
    DateTime? escalatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         type: type,
         severity: severity,
         status: status,
         title: title,
         description: description,
         latitude: latitude,
         longitude: longitude,
         peopleAffected: peopleAffected,
         reportedBy: reportedBy,
         reportedAt: reportedAt,
         updatedAt: updatedAt,
         escalationDueAt: escalationDueAt,
         escalatedAt: escalatedAt,
       );

  /// Returns a shallow copy of this [Incident]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Incident copyWith({
    Object? id = _Undefined,
    _is.UuidValue? organizationId,
    _i3tf8ajh.IncidentType? type,
    _ifp7jacs.IncidentSeverity? severity,
    _ikduxsi0.IncidentStatus? status,
    String? title,
    String? description,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    int? peopleAffected,
    _is.UuidValue? reportedBy,
    DateTime? reportedAt,
    DateTime? updatedAt,
    Object? escalationDueAt = _Undefined,
    Object? escalatedAt = _Undefined,
  }) {
    return Incident(
      id: id is _is.UuidValue? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      peopleAffected: peopleAffected ?? this.peopleAffected,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedAt: reportedAt ?? this.reportedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      escalationDueAt: escalationDueAt is DateTime?
          ? escalationDueAt
          : this.escalationDueAt,
      escalatedAt: escalatedAt is DateTime? ? escalatedAt : this.escalatedAt,
    );
  }
}

class IncidentUpdateTable extends _is.UpdateTable<IncidentTable> {
  IncidentUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> organizationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.organizationId,
    value,
  );

  _is.ColumnValue<_i3tf8ajh.IncidentType, _i3tf8ajh.IncidentType> type(
    _i3tf8ajh.IncidentType value,
  ) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<_ifp7jacs.IncidentSeverity, _ifp7jacs.IncidentSeverity>
  severity(_ifp7jacs.IncidentSeverity value) => _is.ColumnValue(
    table.severity,
    value,
  );

  _is.ColumnValue<_ikduxsi0.IncidentStatus, _ikduxsi0.IncidentStatus> status(
    _ikduxsi0.IncidentStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<double, double> latitude(double? value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double? value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<int, int> peopleAffected(int value) => _is.ColumnValue(
    table.peopleAffected,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> reportedBy(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.reportedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> reportedAt(DateTime value) =>
      _is.ColumnValue(
        table.reportedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> escalationDueAt(DateTime? value) =>
      _is.ColumnValue(
        table.escalationDueAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> escalatedAt(DateTime? value) =>
      _is.ColumnValue(
        table.escalatedAt,
        value,
      );
}

class IncidentTable extends _is.Table<_is.UuidValue?> {
  IncidentTable({super.tableRelation}) : super(tableName: 'relay_incident') {
    updateTable = IncidentUpdateTable(this);
    organizationId = _is.ColumnUuid(
      'organizationId',
      this,
    );
    type = _is.ColumnEnum(
      'type',
      this,
      _is.EnumSerialization.byName,
    );
    severity = _is.ColumnEnum(
      'severity',
      this,
      _is.EnumSerialization.byName,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
    );
    peopleAffected = _is.ColumnInt(
      'peopleAffected',
      this,
    );
    reportedBy = _is.ColumnUuid(
      'reportedBy',
      this,
    );
    reportedAt = _is.ColumnDateTime(
      'reportedAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
    escalationDueAt = _is.ColumnDateTime(
      'escalationDueAt',
      this,
    );
    escalatedAt = _is.ColumnDateTime(
      'escalatedAt',
      this,
    );
  }

  late final IncidentUpdateTable updateTable;

  late final _is.ColumnUuid organizationId;

  late final _is.ColumnEnum<_i3tf8ajh.IncidentType> type;

  late final _is.ColumnEnum<_ifp7jacs.IncidentSeverity> severity;

  late final _is.ColumnEnum<_ikduxsi0.IncidentStatus> status;

  late final _is.ColumnString title;

  late final _is.ColumnString description;

  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnInt peopleAffected;

  late final _is.ColumnUuid reportedBy;

  late final _is.ColumnDateTime reportedAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime escalationDueAt;

  late final _is.ColumnDateTime escalatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    organizationId,
    type,
    severity,
    status,
    title,
    description,
    latitude,
    longitude,
    peopleAffected,
    reportedBy,
    reportedAt,
    updatedAt,
    escalationDueAt,
    escalatedAt,
  ];
}

class IncidentInclude extends _is.IncludeObject {
  IncidentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Incident.t;
}

class IncidentIncludeList extends _is.IncludeList {
  IncidentIncludeList._({
    _is.WhereExpressionBuilder<IncidentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Incident.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Incident.t;
}

class IncidentRepository {
  const IncidentRepository._();

  /// Returns a list of [Incident]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Incident>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Incident>(
      where: where?.call(Incident.t),
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Incident] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Incident?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentTable>? where,
    int? offset,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Incident>(
      where: where?.call(Incident.t),
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Incident] by its [id] or null if no such row exists.
  Future<Incident?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Incident>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Incident]s in the list and returns the inserted rows.
  ///
  /// The returned [Incident]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> insert(
    _is.DatabaseSession session,
    List<Incident> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Incident>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Incident] and returns the inserted row.
  ///
  /// The returned [Incident] will have its `id` field set.
  Future<Incident> insertRow(
    _is.DatabaseSession session,
    Incident row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Incident>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Incident]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Incident]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> upsert(
    _is.DatabaseSession session,
    List<Incident> rows, {
    required _is.ColumnSelections<IncidentTable> conflictColumns,
    _is.ColumnSelections<IncidentTable>? updateColumns,
    _is.WhereExpressionBuilder<IncidentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Incident>(
      rows,
      conflictColumns: conflictColumns(Incident.t),
      updateColumns: updateColumns?.call(Incident.t),
      updateWhere: updateWhere?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Incident] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Incident] will have its `id` field set.
  Future<Incident?> upsertRow(
    _is.DatabaseSession session,
    Incident row, {
    required _is.ColumnSelections<IncidentTable> conflictColumns,
    _is.ColumnSelections<IncidentTable>? updateColumns,
    _is.WhereExpressionBuilder<IncidentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Incident>(
      row,
      conflictColumns: conflictColumns(Incident.t),
      updateColumns: updateColumns?.call(Incident.t),
      updateWhere: updateWhere?.call(Incident.t),
      transaction: transaction,
    );
  }

  /// Updates all [Incident]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> update(
    _is.DatabaseSession session,
    List<Incident> rows, {
    _is.ColumnSelections<IncidentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Incident>(
      rows,
      columns: columns?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Incident]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Incident> updateRow(
    _is.DatabaseSession session,
    Incident row, {
    _is.ColumnSelections<IncidentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Incident>(
      row,
      columns: columns?.call(Incident.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Incident] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Incident?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<IncidentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Incident>(
      id,
      columnValues: columnValues(Incident.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Incident]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IncidentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<IncidentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Incident>(
      columnValues: columnValues(Incident.t.updateTable),
      where: where(Incident.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Incident]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> delete(
    _is.DatabaseSession session,
    List<Incident> rows, {
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Incident>(
      rows,
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Incident].
  Future<Incident> deleteRow(
    _is.DatabaseSession session,
    Incident row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Incident>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IncidentTable> where,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Incident>(
      where: where(Incident.t),
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Incident>(
      where: where?.call(Incident.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Incident] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IncidentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Incident>(
      where: where(Incident.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
