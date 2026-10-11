import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../core/connectivity/connectivity_controller.dart';
import '../../../core/connectivity/connectivity_provider.dart';
import '../../auth/application/access_controller.dart';

final organizationSettingsControllerProvider =
    ChangeNotifierProvider.autoDispose<OrganizationSettingsController>(
      (ref) => OrganizationSettingsController(
        access: ref.read(accessControllerProvider),
        connectivity: ref.read(connectivityControllerProvider),
      ),
    );

/// Online-only membership/team actions, separate from durable incident queues.
class OrganizationSettingsController extends ChangeNotifier {
  OrganizationSettingsController({
    required this.access,
    required this.connectivity,
  }) {
    _scope = _currentScope;
    _online = connectivity.isOnline;
    access.addListener(_accessChanged);
    connectivity.addListener(_connectionChanged);
  }

  final AccessController access;
  final ConnectivityController connectivity;
  List<OrganizationMember> _members = const [];
  List<Team> _teams = const [];
  String? _scope;
  String? _error;
  bool _online = false;
  bool _busy = false;
  bool _loading = false;
  bool _disposed = false;
  int _request = 0;
  int _scopeVersion = 0;

  List<OrganizationMember> get members => List.unmodifiable(_members);
  List<Team> get teams => List.unmodifiable(_teams);
  String? get error => _error;
  bool get busy => _busy;
  bool get loading => _loading;
  bool get canManage => _currentScope != null && connectivity.isOnline;
  bool get canAddMember =>
      canManage && access.context?.membership.role == MemberRole.administrator;
  String? get _currentScope =>
      access.status == AccessStatus.ready && access.isCoordinator
      ? '${access.userId}:${access.context?.organization.id}'
      : null;

  void _accessChanged() {
    if (_scope == _currentScope) return;
    _scope = _currentScope;
    _scopeVersion++;
    _request++;
    _members = const [];
    _teams = const [];
    _error = null;
    _loading = false;
    _busy = false;
    _notify();
  }

  void _connectionChanged() {
    if (_online == connectivity.isOnline) return;
    _online = connectivity.isOnline;
    if (_online) {
      unawaited(load());
    } else {
      _request++;
      _loading = false;
      _error = null;
      _notify();
    }
  }

  Future<void> load() async {
    if (_disposed) return;
    _accessChanged();
    if (!canManage) return;
    final request = ++_request;
    final scopeVersion = _scopeVersion;
    _loading = true;
    _error = null;
    _notify();
    try {
      final members = await access.listMembers();
      if (_disposed || request != _request || scopeVersion != _scopeVersion) {
        return;
      }
      final teams = await access.listTeams();
      if (_disposed || request != _request || scopeVersion != _scopeVersion) {
        return;
      }
      _members = members;
      _teams = teams;
    } catch (_) {
      if (!_disposed && request == _request && scopeVersion == _scopeVersion) {
        _error =
            'Could not reach the workspace. Check your connection and retry.';
      }
    } finally {
      if (!_disposed && request == _request && scopeVersion == _scopeVersion) {
        _loading = false;
        _notify();
      }
    }
  }

  Future<bool> addMember(String rawId, MemberRole role) async {
    if (!canAddMember || _busy || _disposed) return false;
    UuidValue id;
    try {
      id = UuidValue.withValidation(rawId.trim());
    } on FormatException {
      return _reject(
        'Paste the account ID copied by the new member after sign-in.',
      );
    }
    if (id == access.userId) {
      return _reject(
        'This is your account ID. Ask the new member to copy theirs.',
      );
    }
    if (role == MemberRole.administrator) {
      return _reject('Choose Field worker, Responder or Coordinator.');
    }
    if (_members.any((member) => member.authUserId == id)) {
      return _reject('This account is already a member of your organization.');
    }
    return _change(
      () => access.addMember(id, role),
      'Could not add this member. They must sign in first, copy their account ID, and not already belong to another organization.',
    );
  }

  Future<bool> createTeam(String rawName) async {
    final name = rawName.trim();
    if (name.length < 2 || name.length > 80) {
      return _reject('Enter a team name of 2–80 characters.');
    }
    return _change(
      () => access.createTeam(name),
      'Could not create this team. Check your connection and organization access.',
    );
  }

  Future<bool> _change(Future<Object> Function() action, String failure) async {
    if (_disposed || _busy || !canManage) return false;
    final scopeVersion = _scopeVersion;
    _request++;
    _loading = false;
    _busy = true;
    _error = null;
    _notify();
    try {
      await action();
      if (_disposed || scopeVersion != _scopeVersion) return false;
      await load();
      return !_disposed && scopeVersion == _scopeVersion;
    } catch (_) {
      if (!_disposed && scopeVersion == _scopeVersion) _error = failure;
      return false;
    } finally {
      if (!_disposed && scopeVersion == _scopeVersion) {
        _busy = false;
        _notify();
      }
    }
  }

  bool _reject(String message) {
    if (_disposed) return false;
    _error = message;
    _notify();
    return false;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    access.removeListener(_accessChanged);
    connectivity.removeListener(_connectionChanged);
    super.dispose();
  }
}
