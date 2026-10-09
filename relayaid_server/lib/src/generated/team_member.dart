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

abstract class TeamMember
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  TeamMember._({
    this.id,
    required this.teamId,
    required this.authUserId,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory TeamMember({
    _is.UuidValue? id,
    required _is.UuidValue teamId,
    required _is.UuidValue authUserId,
    DateTime? joinedAt,
  }) = _TeamMemberImpl;

  factory TeamMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return TeamMember(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      teamId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['teamId']),
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
    );
  }

  static final t = TeamMemberTable();

  static const db = TeamMemberRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue teamId;

  _is.UuidValue authUserId;

  DateTime joinedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TeamMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TeamMember copyWith({
    _is.UuidValue? id,
    _is.UuidValue? teamId,
    _is.UuidValue? authUserId,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamMember',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      'authUserId': authUserId.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TeamMember',
      if (id != null) 'id': id?.toJson(),
      'teamId': teamId.toJson(),
      'authUserId': authUserId.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  static TeamMemberInclude include() {
    return TeamMemberInclude._();
  }

  static TeamMemberIncludeList includeList({
    _is.WhereExpressionBuilder<TeamMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamMemberTable>? orderBy,
    _is.OrderByListBuilder<TeamMemberTable>? orderByList,
    TeamMemberInclude? include,
  }) {
    return TeamMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TeamMember.t),
      orderByList: orderByList?.call(TeamMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TeamMemberImpl extends TeamMember {
  _TeamMemberImpl({
    _is.UuidValue? id,
    required _is.UuidValue teamId,
    required _is.UuidValue authUserId,
    DateTime? joinedAt,
  }) : super._(
         id: id,
         teamId: teamId,
         authUserId: authUserId,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [TeamMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TeamMember copyWith({
    Object? id = _Undefined,
    _is.UuidValue? teamId,
    _is.UuidValue? authUserId,
    DateTime? joinedAt,
  }) {
    return TeamMember(
      id: id is _is.UuidValue? ? id : this.id,
      teamId: teamId ?? this.teamId,
      authUserId: authUserId ?? this.authUserId,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class TeamMemberUpdateTable extends _is.UpdateTable<TeamMemberTable> {
  TeamMemberUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> teamId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.teamId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _is.ColumnValue(
        table.joinedAt,
        value,
      );
}

class TeamMemberTable extends _is.Table<_is.UuidValue?> {
  TeamMemberTable({super.tableRelation})
    : super(tableName: 'relay_team_member') {
    updateTable = TeamMemberUpdateTable(this);
    teamId = _is.ColumnUuid(
      'teamId',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    joinedAt = _is.ColumnDateTime(
      'joinedAt',
      this,
      hasDefault: true,
    );
  }

  late final TeamMemberUpdateTable updateTable;

  late final _is.ColumnUuid teamId;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnDateTime joinedAt;

  @override
  List<_is.Column> get columns => [
    id,
    teamId,
    authUserId,
    joinedAt,
  ];
}

class TeamMemberInclude extends _is.IncludeObject {
  TeamMemberInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => TeamMember.t;
}

class TeamMemberIncludeList extends _is.IncludeList {
  TeamMemberIncludeList._({
    _is.WhereExpressionBuilder<TeamMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TeamMember.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => TeamMember.t;
}

class TeamMemberRepository {
  const TeamMemberRepository._();

  /// Returns a list of [TeamMember]s matching the given query parameters.
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
  Future<List<TeamMember>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamMemberTable>? orderBy,
    _is.OrderByListBuilder<TeamMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TeamMember>(
      where: where?.call(TeamMember.t),
      orderBy: orderBy?.call(TeamMember.t),
      orderByList: orderByList?.call(TeamMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TeamMember] matching the given query parameters.
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
  Future<TeamMember?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamMemberTable>? where,
    int? offset,
    _is.OrderByBuilder<TeamMemberTable>? orderBy,
    _is.OrderByListBuilder<TeamMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TeamMember>(
      where: where?.call(TeamMember.t),
      orderBy: orderBy?.call(TeamMember.t),
      orderByList: orderByList?.call(TeamMember.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TeamMember] by its [id] or null if no such row exists.
  Future<TeamMember?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TeamMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TeamMember]s in the list and returns the inserted rows.
  ///
  /// The returned [TeamMember]s will have their `id` fields set.
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
  Future<List<TeamMember>> insert(
    _is.DatabaseSession session,
    List<TeamMember> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TeamMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TeamMember] and returns the inserted row.
  ///
  /// The returned [TeamMember] will have its `id` field set.
  Future<TeamMember> insertRow(
    _is.DatabaseSession session,
    TeamMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TeamMember>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TeamMember]s in the list and returns the resulting rows.
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
  /// The returned [TeamMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamMember>> upsert(
    _is.DatabaseSession session,
    List<TeamMember> rows, {
    required _is.ColumnSelections<TeamMemberTable> conflictColumns,
    _is.ColumnSelections<TeamMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamMemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TeamMember>(
      rows,
      conflictColumns: conflictColumns(TeamMember.t),
      updateColumns: updateColumns?.call(TeamMember.t),
      updateWhere: updateWhere?.call(TeamMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TeamMember] and returns the resulting row.
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
  /// The returned [TeamMember] will have its `id` field set.
  Future<TeamMember?> upsertRow(
    _is.DatabaseSession session,
    TeamMember row, {
    required _is.ColumnSelections<TeamMemberTable> conflictColumns,
    _is.ColumnSelections<TeamMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<TeamMemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TeamMember>(
      row,
      conflictColumns: conflictColumns(TeamMember.t),
      updateColumns: updateColumns?.call(TeamMember.t),
      updateWhere: updateWhere?.call(TeamMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [TeamMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamMember>> update(
    _is.DatabaseSession session,
    List<TeamMember> rows, {
    _is.ColumnSelections<TeamMemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TeamMember>(
      rows,
      columns: columns?.call(TeamMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TeamMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TeamMember> updateRow(
    _is.DatabaseSession session,
    TeamMember row, {
    _is.ColumnSelections<TeamMemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TeamMember>(
      row,
      columns: columns?.call(TeamMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TeamMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TeamMember?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TeamMemberUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TeamMember>(
      id,
      columnValues: columnValues(TeamMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TeamMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TeamMember>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TeamMemberUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TeamMemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TeamMemberTable>? orderBy,
    _is.OrderByListBuilder<TeamMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TeamMember>(
      columnValues: columnValues(TeamMember.t.updateTable),
      where: where(TeamMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TeamMember.t),
      orderByList: orderByList?.call(TeamMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TeamMember]s in the list and returns the deleted rows.
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
  Future<List<TeamMember>> delete(
    _is.DatabaseSession session,
    List<TeamMember> rows, {
    _is.OrderByBuilder<TeamMemberTable>? orderBy,
    _is.OrderByListBuilder<TeamMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TeamMember>(
      rows,
      orderBy: orderBy?.call(TeamMember.t),
      orderByList: orderByList?.call(TeamMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TeamMember].
  Future<TeamMember> deleteRow(
    _is.DatabaseSession session,
    TeamMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TeamMember>(
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
  Future<List<TeamMember>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamMemberTable> where,
    _is.OrderByBuilder<TeamMemberTable>? orderBy,
    _is.OrderByListBuilder<TeamMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TeamMember>(
      where: where(TeamMember.t),
      orderBy: orderBy?.call(TeamMember.t),
      orderByList: orderByList?.call(TeamMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TeamMemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TeamMember>(
      where: where?.call(TeamMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TeamMember] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TeamMemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TeamMember>(
      where: where(TeamMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
