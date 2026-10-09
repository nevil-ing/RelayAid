import 'package:flutter/foundation.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../core/connectivity/connectivity_controller.dart';
import '../../auth/application/access_controller.dart';
import '../domain/team_repository.dart';

/// Team forms delegate validation and persistence here; rosters arrive via the
/// command-center feed, so team availability and counts stay live.
class TeamController extends ChangeNotifier {
  TeamController({
    required this.repository,
    required this.access,
    required this.connectivity,
  }) {
    access.addListener(_accessChanged);
  }
  final TeamRepository repository;
  final AccessController access;
  final ConnectivityController connectivity;
  List<OrganizationMember> _members = const [];
  String? _scope;
  String? _error;
  bool _busy = false;
  bool _loading = false;
  bool _disposed = false;
  int _request = 0;

  List<OrganizationMember> get responders =>
      _members.where((m) => m.role == MemberRole.responder).toList();
  String? get error => _error;
  bool get busy => _busy;
  bool get loading => _loading;
  String? get _currentScope =>
      access.status == AccessStatus.ready && access.isCoordinator
      ? '${access.userId}:${access.context?.organization.id}'
      : null;

  void _accessChanged() {
    if (_scope == _currentScope) return;
    _request++;
    _scope = _currentScope;
    _members = const [];
    _error = null;
    _busy = false;
    _loading = false;
    if (!_disposed) notifyListeners();
  }

  Future<void> loadMembers() async {
    _accessChanged();
    if (_scope == null) return;
    final request = ++_request;
    final scope = _scope;
    _loading = true;
    notifyListeners();
    try {
      final members = await repository.members(
        access.context!.organization.id!,
      );
      if (!_disposed && scope == _currentScope && request == _request) {
        _members = members;
        _error = null;
      }
    } catch (_) {
      if (!_disposed && scope == _currentScope && request == _request) {
        _error = 'Could not load responders. Reconnect and try again.';
      }
    } finally {
      if (!_disposed && scope == _currentScope && request == _request) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> create(String name) async {
    if (name.trim().length < 2 || name.trim().length > 80) {
      _error = 'Enter a team name of 2–80 characters.';
      notifyListeners();
      return false;
    }
    return _change(
      () => repository.create(access.context!.organization.id!, name.trim()),
    );
  }

  Future<bool> addResponder(UuidValue teamId, UuidValue responderId) =>
      _change(() => repository.addResponder(teamId, responderId));

  Future<bool> _change(Future<Object> Function() action) async {
    if (_busy || _disposed || !access.isCoordinator || _currentScope == null) {
      return false;
    }
    if (!connectivity.isOnline) {
      _error =
          'Reconnect before changing teams. Offline changes are not queued.';
      notifyListeners();
      return false;
    }
    final scope = _currentScope;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return !_disposed && scope == _currentScope;
    } catch (_) {
      if (!_disposed && scope == _currentScope) {
        _error =
            'Team could not be updated. Check the name, responder and your access.';
      }
      return false;
    } finally {
      if (!_disposed && scope == _currentScope) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    access.removeListener(_accessChanged);
    super.dispose();
  }
}
