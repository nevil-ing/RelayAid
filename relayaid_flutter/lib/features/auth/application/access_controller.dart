import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../domain/access_context_cache.dart';
import '../domain/auth_gateway.dart';

enum AccessStatus { loading, signedOut, needsOrganization, ready, unavailable }

final accessControllerProvider = Provider<AccessController>((ref) {
  throw StateError('AccessController must be provided at startup.');
});

class AccessController extends ChangeNotifier {
  AccessController(this.gateway, {this.contextCache}) {
    gateway.addListener(_onIdentityChanged);
  }

  final AuthGateway gateway;
  final AccessContextCache? contextCache;
  AccessStatus _status = AccessStatus.loading;
  OrganizationContext? _context;
  bool _isContextCached = false;
  int _requestVersion = 0;

  AccessStatus get status => _status;
  OrganizationContext? get context => _context;
  bool get isContextCached => _isContextCached;
  UuidValue? get userId => gateway.userId;
  bool get isCoordinator => switch (_context?.membership.role) {
    MemberRole.coordinator || MemberRole.administrator => true,
    _ => false,
  };

  Future<void> initialize() async {
    await gateway.restore();
    await refresh();
  }

  void _onIdentityChanged() {
    unawaited(refresh());
  }

  Future<void> refresh() async {
    final version = ++_requestVersion;
    if (!gateway.isAuthenticated) {
      _context = null;
      _isContextCached = false;
      _setStatus(AccessStatus.signedOut);
      return;
    }
    _setStatus(AccessStatus.loading);
    try {
      final nextContext = await gateway.myContext();
      if (version != _requestVersion) return;
      _context = nextContext;
      _isContextCached = false;
      if (nextContext != null) {
        await contextCache?.write(nextContext);
      } else {
        final userId = gateway.userId;
        if (userId != null) await contextCache?.remove(userId);
      }
      _setStatus(
        nextContext == null
            ? AccessStatus.needsOrganization
            : AccessStatus.ready,
      );
    } catch (_) {
      if (version != _requestVersion) return;
      final userId = gateway.userId;
      OrganizationContext? cached;
      try {
        cached = userId == null ? null : await contextCache?.read(userId);
      } catch (_) {
        cached = null;
      }
      if (cached != null && cached.membership.authUserId == userId) {
        _context = cached;
        _isContextCached = true;
        _setStatus(AccessStatus.ready);
        return;
      }
      _setStatus(AccessStatus.unavailable);
    }
  }

  Future<void> createOrganization(String name) async {
    final created = await gateway.createOrganization(name);
    _context = created;
    _isContextCached = false;
    await contextCache?.write(created);
    _setStatus(AccessStatus.ready);
  }

  Future<void> signOut() async {
    final userId = gateway.userId;
    await gateway.signOut();
    if (userId != null) await contextCache?.remove(userId);
    _context = null;
    _isContextCached = false;
    _setStatus(AccessStatus.signedOut);
  }

  Future<List<OrganizationMember>> listMembers() {
    final organizationId = _context?.organization.id;
    if (organizationId == null) throw StateError('No organization loaded.');
    return gateway.listMembers(organizationId);
  }

  Future<OrganizationMember> addMember(UuidValue userId, MemberRole role) {
    final organizationId = _context?.organization.id;
    if (organizationId == null) throw StateError('No organization loaded.');
    return gateway.addMember(organizationId, userId, role);
  }

  Future<List<Team>> listTeams() {
    final organizationId = _context?.organization.id;
    if (organizationId == null) throw StateError('No organization loaded.');
    return gateway.listTeams(organizationId);
  }

  Future<Team> createTeam(String name) {
    final organizationId = _context?.organization.id;
    if (organizationId == null) throw StateError('No organization loaded.');
    return gateway.createTeam(organizationId, name);
  }

  void _setStatus(AccessStatus next) {
    _status = next;
    notifyListeners();
  }

  @override
  void dispose() {
    gateway.removeListener(_onIdentityChanged);
    super.dispose();
  }
}
