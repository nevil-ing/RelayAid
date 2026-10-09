import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/components/app_button.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../auth/application/access_controller.dart';

class OrganizationSettingsPage extends ConsumerStatefulWidget {
  const OrganizationSettingsPage({super.key});

  @override
  ConsumerState<OrganizationSettingsPage> createState() =>
      _OrganizationSettingsPageState();
}

class _OrganizationSettingsPageState
    extends ConsumerState<OrganizationSettingsPage> {
  final _userId = TextEditingController();
  final _teamName = TextEditingController();
  MemberRole _role = MemberRole.fieldWorker;
  List<OrganizationMember> _members = const [];
  List<Team> _teams = const [];
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _userId.dispose();
    _teamName.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    try {
      final access = ref.read(accessControllerProvider);
      final members = await access.listMembers();
      final teams = await access.listTeams();
      if (mounted) {
        setState(() {
          _members = members;
          _teams = teams;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not load organization settings.');
      }
    }
  }

  Future<void> _addMember() async {
    UuidValue userId;
    try {
      userId = UuidValue.fromString(_userId.text.trim());
    } catch (_) {
      setState(() => _error = 'Enter a valid user ID.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accessControllerProvider).addMember(userId, _role);
      _userId.clear();
      await _reload();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Member could not be added. Check the ID and access.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createTeam() async {
    if (_teamName.text.trim().length < 2) {
      setState(() => _error = 'Enter a team name of at least 2 characters.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accessControllerProvider).createTeam(_teamName.text);
      _teamName.clear();
      await _reload();
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Team could not be created. Check the name and access.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(accessControllerProvider);
    final isAdmin = access.context?.membership.role == MemberRole.administrator;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        Text('Organization settings', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.space8),
        Text(access.context?.organization.name ?? ''),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.space16),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: AppSpacing.space32),
        Text('Members', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space8),
        for (final member in _members)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: SelectableText(member.authUserId.toString()),
            subtitle: Text(member.role.name),
          ),
        if (isAdmin) ...[
          const SizedBox(height: AppSpacing.space16),
          TextField(
            controller: _userId,
            decoration: const InputDecoration(labelText: 'New member user ID'),
          ),
          const SizedBox(height: AppSpacing.space8),
          DropdownButtonFormField<MemberRole>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(
                value: MemberRole.fieldWorker,
                child: Text('Field worker'),
              ),
              DropdownMenuItem(
                value: MemberRole.responder,
                child: Text('Responder'),
              ),
              DropdownMenuItem(
                value: MemberRole.coordinator,
                child: Text('Coordinator'),
              ),
            ],
            onChanged: (role) {
              if (role != null) setState(() => _role = role);
            },
          ),
          const SizedBox(height: AppSpacing.space16),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'Add member',
              onPressed: _busy ? null : _addMember,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space32),
        Text('Teams', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space8),
        for (final team in _teams)
          ListTile(contentPadding: EdgeInsets.zero, title: Text(team.name)),
        TextField(
          controller: _teamName,
          decoration: const InputDecoration(labelText: 'New team name'),
          maxLength: 80,
        ),
        const SizedBox(height: AppSpacing.space16),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            label: 'Create team',
            onPressed: _busy ? null : _createTeam,
          ),
        ),
        const SizedBox(height: AppSpacing.space32),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.secondary,
            onPressed: access.signOut,
          ),
        ),
      ],
    );
  }
}
