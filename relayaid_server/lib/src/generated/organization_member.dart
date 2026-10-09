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
import 'member_role.dart' as _insyygng;

abstract class OrganizationMember
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  OrganizationMember._({
    this.id,
    required this.organizationId,
    required this.authUserId,
    required this.role,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory OrganizationMember({
    _is.UuidValue? id,
    required _is.UuidValue organizationId,
    required _is.UuidValue authUserId,
    required _insyygng.MemberRole role,
    DateTime? joinedAt,
  }) = _OrganizationMemberImpl;

  factory OrganizationMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrganizationMember(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      organizationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['organizationId'],
      ),
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      role: _insyygng.MemberRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
    );
  }

  static final t = OrganizationMemberTable();

  static const db = OrganizationMemberRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue organizationId;

  _is.UuidValue authUserId;

  _insyygng.MemberRole role;

  DateTime joinedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [OrganizationMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OrganizationMember copyWith({
    _is.UuidValue? id,
    _is.UuidValue? organizationId,
    _is.UuidValue? authUserId,
    _insyygng.MemberRole? role,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrganizationMember',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrganizationMember',
      if (id != null) 'id': id?.toJson(),
      'organizationId': organizationId.toJson(),
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  static OrganizationMemberInclude include() {
    return OrganizationMemberInclude._();
  }

  static OrganizationMemberIncludeList includeList({
    _is.WhereExpressionBuilder<OrganizationMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OrganizationMemberTable>? orderBy,
    _is.OrderByListBuilder<OrganizationMemberTable>? orderByList,
    OrganizationMemberInclude? include,
  }) {
    return OrganizationMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OrganizationMember.t),
      orderByList: orderByList?.call(OrganizationMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrganizationMemberImpl extends OrganizationMember {
  _OrganizationMemberImpl({
    _is.UuidValue? id,
    required _is.UuidValue organizationId,
    required _is.UuidValue authUserId,
    required _insyygng.MemberRole role,
    DateTime? joinedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         authUserId: authUserId,
         role: role,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [OrganizationMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OrganizationMember copyWith({
    Object? id = _Undefined,
    _is.UuidValue? organizationId,
    _is.UuidValue? authUserId,
    _insyygng.MemberRole? role,
    DateTime? joinedAt,
  }) {
    return OrganizationMember(
      id: id is _is.UuidValue? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      authUserId: authUserId ?? this.authUserId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class OrganizationMemberUpdateTable
    extends _is.UpdateTable<OrganizationMemberTable> {
  OrganizationMemberUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> organizationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.organizationId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<_insyygng.MemberRole, _insyygng.MemberRole> role(
    _insyygng.MemberRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _is.ColumnValue(
        table.joinedAt,
        value,
      );
}

class OrganizationMemberTable extends _is.Table<_is.UuidValue?> {
  OrganizationMemberTable({super.tableRelation})
    : super(tableName: 'relay_organization_member') {
    updateTable = OrganizationMemberUpdateTable(this);
    organizationId = _is.ColumnUuid(
      'organizationId',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    joinedAt = _is.ColumnDateTime(
      'joinedAt',
      this,
      hasDefault: true,
    );
  }

  late final OrganizationMemberUpdateTable updateTable;

  late final _is.ColumnUuid organizationId;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnEnum<_insyygng.MemberRole> role;

  late final _is.ColumnDateTime joinedAt;

  @override
  List<_is.Column> get columns => [
    id,
    organizationId,
    authUserId,
    role,
    joinedAt,
  ];
}

class OrganizationMemberInclude extends _is.IncludeObject {
  OrganizationMemberInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => OrganizationMember.t;
}

class OrganizationMemberIncludeList extends _is.IncludeList {
  OrganizationMemberIncludeList._({
    _is.WhereExpressionBuilder<OrganizationMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OrganizationMember.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => OrganizationMember.t;
}

class OrganizationMemberRepository {
  const OrganizationMemberRepository._();

  /// Returns a list of [OrganizationMember]s matching the given query parameters.
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
  Future<List<OrganizationMember>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OrganizationMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OrganizationMemberTable>? orderBy,
    _is.OrderByListBuilder<OrganizationMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OrganizationMember>(
      where: where?.call(OrganizationMember.t),
      orderBy: orderBy?.call(OrganizationMember.t),
      orderByList: orderByList?.call(OrganizationMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OrganizationMember] matching the given query parameters.
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
  Future<OrganizationMember?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OrganizationMemberTable>? where,
    int? offset,
    _is.OrderByBuilder<OrganizationMemberTable>? orderBy,
    _is.OrderByListBuilder<OrganizationMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OrganizationMember>(
      where: where?.call(OrganizationMember.t),
      orderBy: orderBy?.call(OrganizationMember.t),
      orderByList: orderByList?.call(OrganizationMember.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OrganizationMember] by its [id] or null if no such row exists.
  Future<OrganizationMember?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OrganizationMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OrganizationMember]s in the list and returns the inserted rows.
  ///
  /// The returned [OrganizationMember]s will have their `id` fields set.
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
  Future<List<OrganizationMember>> insert(
    _is.DatabaseSession session,
    List<OrganizationMember> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<OrganizationMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [OrganizationMember] and returns the inserted row.
  ///
  /// The returned [OrganizationMember] will have its `id` field set.
  Future<OrganizationMember> insertRow(
    _is.DatabaseSession session,
    OrganizationMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<OrganizationMember>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [OrganizationMember]s in the list and returns the resulting rows.
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
  /// The returned [OrganizationMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OrganizationMember>> upsert(
    _is.DatabaseSession session,
    List<OrganizationMember> rows, {
    required _is.ColumnSelections<OrganizationMemberTable> conflictColumns,
    _is.ColumnSelections<OrganizationMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<OrganizationMemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<OrganizationMember>(
      rows,
      conflictColumns: conflictColumns(OrganizationMember.t),
      updateColumns: updateColumns?.call(OrganizationMember.t),
      updateWhere: updateWhere?.call(OrganizationMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [OrganizationMember] and returns the resulting row.
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
  /// The returned [OrganizationMember] will have its `id` field set.
  Future<OrganizationMember?> upsertRow(
    _is.DatabaseSession session,
    OrganizationMember row, {
    required _is.ColumnSelections<OrganizationMemberTable> conflictColumns,
    _is.ColumnSelections<OrganizationMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<OrganizationMemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<OrganizationMember>(
      row,
      conflictColumns: conflictColumns(OrganizationMember.t),
      updateColumns: updateColumns?.call(OrganizationMember.t),
      updateWhere: updateWhere?.call(OrganizationMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [OrganizationMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OrganizationMember>> update(
    _is.DatabaseSession session,
    List<OrganizationMember> rows, {
    _is.ColumnSelections<OrganizationMemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<OrganizationMember>(
      rows,
      columns: columns?.call(OrganizationMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [OrganizationMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OrganizationMember> updateRow(
    _is.DatabaseSession session,
    OrganizationMember row, {
    _is.ColumnSelections<OrganizationMemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<OrganizationMember>(
      row,
      columns: columns?.call(OrganizationMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OrganizationMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OrganizationMember?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<OrganizationMemberUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<OrganizationMember>(
      id,
      columnValues: columnValues(OrganizationMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OrganizationMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OrganizationMember>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OrganizationMemberUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<OrganizationMemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OrganizationMemberTable>? orderBy,
    _is.OrderByListBuilder<OrganizationMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<OrganizationMember>(
      columnValues: columnValues(OrganizationMember.t.updateTable),
      where: where(OrganizationMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OrganizationMember.t),
      orderByList: orderByList?.call(OrganizationMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [OrganizationMember]s in the list and returns the deleted rows.
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
  Future<List<OrganizationMember>> delete(
    _is.DatabaseSession session,
    List<OrganizationMember> rows, {
    _is.OrderByBuilder<OrganizationMemberTable>? orderBy,
    _is.OrderByListBuilder<OrganizationMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<OrganizationMember>(
      rows,
      orderBy: orderBy?.call(OrganizationMember.t),
      orderByList: orderByList?.call(OrganizationMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [OrganizationMember].
  Future<OrganizationMember> deleteRow(
    _is.DatabaseSession session,
    OrganizationMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OrganizationMember>(
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
  Future<List<OrganizationMember>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OrganizationMemberTable> where,
    _is.OrderByBuilder<OrganizationMemberTable>? orderBy,
    _is.OrderByListBuilder<OrganizationMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<OrganizationMember>(
      where: where(OrganizationMember.t),
      orderBy: orderBy?.call(OrganizationMember.t),
      orderByList: orderByList?.call(OrganizationMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OrganizationMemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<OrganizationMember>(
      where: where?.call(OrganizationMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OrganizationMember] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OrganizationMemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OrganizationMember>(
      where: where(OrganizationMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
