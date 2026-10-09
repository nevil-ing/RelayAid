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

abstract class IncidentAttachment
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  IncidentAttachment._({
    this.id,
    required this.incidentId,
    required this.organizationId,
    required this.uploadedBy,
    required this.contentType,
    required this.byteLength,
    this.storagePath,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory IncidentAttachment({
    _is.UuidValue? id,
    required _is.UuidValue incidentId,
    required _is.UuidValue organizationId,
    required _is.UuidValue uploadedBy,
    required String contentType,
    required int byteLength,
    String? storagePath,
    DateTime? uploadedAt,
  }) = _IncidentAttachmentImpl;

  factory IncidentAttachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentAttachment(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      incidentId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['incidentId'],
      ),
      organizationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      uploadedBy: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['uploadedBy'],
      ),
      contentType: jsonSerialization['contentType'] as String,
      byteLength: jsonSerialization['byteLength'] as int,
      storagePath: jsonSerialization['storagePath'] as String?,
      uploadedAt: jsonSerialization['uploadedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['uploadedAt']),
    );
  }

  static final t = IncidentAttachmentTable();

  static const db = IncidentAttachmentRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue incidentId;

  _is.UuidValue organizationId;

  _is.UuidValue uploadedBy;

  String contentType;

  int byteLength;

  String? storagePath;

  DateTime uploadedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [IncidentAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IncidentAttachment copyWith({
    _is.UuidValue? id,
    _is.UuidValue? incidentId,
    _is.UuidValue? organizationId,
    _is.UuidValue? uploadedBy,
    String? contentType,
    int? byteLength,
    String? storagePath,
    DateTime? uploadedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentAttachment',
      if (id != null) 'id': id?.toJson(),
      'incidentId': incidentId.toJson(),
      'organizationId': organizationId.toJson(),
      'uploadedBy': uploadedBy.toJson(),
      'contentType': contentType,
      'byteLength': byteLength,
      if (storagePath != null) 'storagePath': storagePath,
      'uploadedAt': uploadedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentAttachment',
      if (id != null) 'id': id?.toJson(),
      'incidentId': incidentId.toJson(),
      'organizationId': organizationId.toJson(),
      'uploadedBy': uploadedBy.toJson(),
      'contentType': contentType,
      'byteLength': byteLength,
      'uploadedAt': uploadedAt.toJson(),
    };
  }

  static IncidentAttachmentInclude include() {
    return IncidentAttachmentInclude._();
  }

  static IncidentAttachmentIncludeList includeList({
    _is.WhereExpressionBuilder<IncidentAttachmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentAttachmentTable>? orderBy,
    _is.OrderByListBuilder<IncidentAttachmentTable>? orderByList,
    IncidentAttachmentInclude? include,
  }) {
    return IncidentAttachmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IncidentAttachment.t),
      orderByList: orderByList?.call(IncidentAttachment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentAttachmentImpl extends IncidentAttachment {
  _IncidentAttachmentImpl({
    _is.UuidValue? id,
    required _is.UuidValue incidentId,
    required _is.UuidValue organizationId,
    required _is.UuidValue uploadedBy,
    required String contentType,
    required int byteLength,
    String? storagePath,
    DateTime? uploadedAt,
  }) : super._(
         id: id,
         incidentId: incidentId,
         organizationId: organizationId,
         uploadedBy: uploadedBy,
         contentType: contentType,
         byteLength: byteLength,
         storagePath: storagePath,
         uploadedAt: uploadedAt,
       );

  /// Returns a shallow copy of this [IncidentAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IncidentAttachment copyWith({
    Object? id = _Undefined,
    _is.UuidValue? incidentId,
    _is.UuidValue? organizationId,
    _is.UuidValue? uploadedBy,
    String? contentType,
    int? byteLength,
    Object? storagePath = _Undefined,
    DateTime? uploadedAt,
  }) {
    return IncidentAttachment(
      id: id is _is.UuidValue? ? id : this.id,
      incidentId: incidentId ?? this.incidentId,
      organizationId: organizationId ?? this.organizationId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      contentType: contentType ?? this.contentType,
      byteLength: byteLength ?? this.byteLength,
      storagePath: storagePath is String? ? storagePath : this.storagePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

class IncidentAttachmentUpdateTable
    extends _is.UpdateTable<IncidentAttachmentTable> {
  IncidentAttachmentUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> incidentId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.incidentId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> organizationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.organizationId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> uploadedBy(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.uploadedBy,
    value,
  );

  _is.ColumnValue<String, String> contentType(String value) => _is.ColumnValue(
    table.contentType,
    value,
  );

  _is.ColumnValue<int, int> byteLength(int value) => _is.ColumnValue(
    table.byteLength,
    value,
  );

  _is.ColumnValue<String, String> storagePath(String? value) => _is.ColumnValue(
    table.storagePath,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> uploadedAt(DateTime value) =>
      _is.ColumnValue(
        table.uploadedAt,
        value,
      );
}

class IncidentAttachmentTable extends _is.Table<_is.UuidValue?> {
  IncidentAttachmentTable({super.tableRelation})
    : super(tableName: 'relay_incident_attachment') {
    updateTable = IncidentAttachmentUpdateTable(this);
    incidentId = _is.ColumnUuid(
      'incidentId',
      this,
    );
    organizationId = _is.ColumnUuid(
      'organizationId',
      this,
    );
    uploadedBy = _is.ColumnUuid(
      'uploadedBy',
      this,
    );
    contentType = _is.ColumnString(
      'contentType',
      this,
    );
    byteLength = _is.ColumnInt(
      'byteLength',
      this,
    );
    storagePath = _is.ColumnString(
      'storagePath',
      this,
    );
    uploadedAt = _is.ColumnDateTime(
      'uploadedAt',
      this,
      hasDefault: true,
    );
  }

  late final IncidentAttachmentUpdateTable updateTable;

  late final _is.ColumnUuid incidentId;

  late final _is.ColumnUuid organizationId;

  late final _is.ColumnUuid uploadedBy;

  late final _is.ColumnString contentType;

  late final _is.ColumnInt byteLength;

  late final _is.ColumnString storagePath;

  late final _is.ColumnDateTime uploadedAt;

  @override
  List<_is.Column> get columns => [
    id,
    incidentId,
    organizationId,
    uploadedBy,
    contentType,
    byteLength,
    storagePath,
    uploadedAt,
  ];
}

class IncidentAttachmentInclude extends _is.IncludeObject {
  IncidentAttachmentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => IncidentAttachment.t;
}

class IncidentAttachmentIncludeList extends _is.IncludeList {
  IncidentAttachmentIncludeList._({
    _is.WhereExpressionBuilder<IncidentAttachmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IncidentAttachment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => IncidentAttachment.t;
}

class IncidentAttachmentRepository {
  const IncidentAttachmentRepository._();

  /// Returns a list of [IncidentAttachment]s matching the given query parameters.
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
  Future<List<IncidentAttachment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentAttachmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentAttachmentTable>? orderBy,
    _is.OrderByListBuilder<IncidentAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<IncidentAttachment>(
      where: where?.call(IncidentAttachment.t),
      orderBy: orderBy?.call(IncidentAttachment.t),
      orderByList: orderByList?.call(IncidentAttachment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [IncidentAttachment] matching the given query parameters.
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
  Future<IncidentAttachment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentAttachmentTable>? where,
    int? offset,
    _is.OrderByBuilder<IncidentAttachmentTable>? orderBy,
    _is.OrderByListBuilder<IncidentAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<IncidentAttachment>(
      where: where?.call(IncidentAttachment.t),
      orderBy: orderBy?.call(IncidentAttachment.t),
      orderByList: orderByList?.call(IncidentAttachment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [IncidentAttachment] by its [id] or null if no such row exists.
  Future<IncidentAttachment?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<IncidentAttachment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [IncidentAttachment]s in the list and returns the inserted rows.
  ///
  /// The returned [IncidentAttachment]s will have their `id` fields set.
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
  Future<List<IncidentAttachment>> insert(
    _is.DatabaseSession session,
    List<IncidentAttachment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<IncidentAttachment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [IncidentAttachment] and returns the inserted row.
  ///
  /// The returned [IncidentAttachment] will have its `id` field set.
  Future<IncidentAttachment> insertRow(
    _is.DatabaseSession session,
    IncidentAttachment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<IncidentAttachment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [IncidentAttachment]s in the list and returns the resulting rows.
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
  /// The returned [IncidentAttachment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IncidentAttachment>> upsert(
    _is.DatabaseSession session,
    List<IncidentAttachment> rows, {
    required _is.ColumnSelections<IncidentAttachmentTable> conflictColumns,
    _is.ColumnSelections<IncidentAttachmentTable>? updateColumns,
    _is.WhereExpressionBuilder<IncidentAttachmentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<IncidentAttachment>(
      rows,
      conflictColumns: conflictColumns(IncidentAttachment.t),
      updateColumns: updateColumns?.call(IncidentAttachment.t),
      updateWhere: updateWhere?.call(IncidentAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [IncidentAttachment] and returns the resulting row.
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
  /// The returned [IncidentAttachment] will have its `id` field set.
  Future<IncidentAttachment?> upsertRow(
    _is.DatabaseSession session,
    IncidentAttachment row, {
    required _is.ColumnSelections<IncidentAttachmentTable> conflictColumns,
    _is.ColumnSelections<IncidentAttachmentTable>? updateColumns,
    _is.WhereExpressionBuilder<IncidentAttachmentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<IncidentAttachment>(
      row,
      conflictColumns: conflictColumns(IncidentAttachment.t),
      updateColumns: updateColumns?.call(IncidentAttachment.t),
      updateWhere: updateWhere?.call(IncidentAttachment.t),
      transaction: transaction,
    );
  }

  /// Updates all [IncidentAttachment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IncidentAttachment>> update(
    _is.DatabaseSession session,
    List<IncidentAttachment> rows, {
    _is.ColumnSelections<IncidentAttachmentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<IncidentAttachment>(
      rows,
      columns: columns?.call(IncidentAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [IncidentAttachment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IncidentAttachment> updateRow(
    _is.DatabaseSession session,
    IncidentAttachment row, {
    _is.ColumnSelections<IncidentAttachmentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<IncidentAttachment>(
      row,
      columns: columns?.call(IncidentAttachment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IncidentAttachment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IncidentAttachment?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<IncidentAttachmentUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<IncidentAttachment>(
      id,
      columnValues: columnValues(IncidentAttachment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IncidentAttachment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IncidentAttachment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IncidentAttachmentUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<IncidentAttachmentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentAttachmentTable>? orderBy,
    _is.OrderByListBuilder<IncidentAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<IncidentAttachment>(
      columnValues: columnValues(IncidentAttachment.t.updateTable),
      where: where(IncidentAttachment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IncidentAttachment.t),
      orderByList: orderByList?.call(IncidentAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [IncidentAttachment]s in the list and returns the deleted rows.
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
  Future<List<IncidentAttachment>> delete(
    _is.DatabaseSession session,
    List<IncidentAttachment> rows, {
    _is.OrderByBuilder<IncidentAttachmentTable>? orderBy,
    _is.OrderByListBuilder<IncidentAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<IncidentAttachment>(
      rows,
      orderBy: orderBy?.call(IncidentAttachment.t),
      orderByList: orderByList?.call(IncidentAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [IncidentAttachment].
  Future<IncidentAttachment> deleteRow(
    _is.DatabaseSession session,
    IncidentAttachment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IncidentAttachment>(
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
  Future<List<IncidentAttachment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IncidentAttachmentTable> where,
    _is.OrderByBuilder<IncidentAttachmentTable>? orderBy,
    _is.OrderByListBuilder<IncidentAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<IncidentAttachment>(
      where: where(IncidentAttachment.t),
      orderBy: orderBy?.call(IncidentAttachment.t),
      orderByList: orderByList?.call(IncidentAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentAttachmentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<IncidentAttachment>(
      where: where?.call(IncidentAttachment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [IncidentAttachment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IncidentAttachmentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<IncidentAttachment>(
      where: where(IncidentAttachment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
