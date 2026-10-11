import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../design_system/components/app_button.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../shared/presentation/connection_help.dart';
import '../../../shared/presentation/member_id_view.dart';
import '../../../shared/presentation/member_role_label.dart';
import '../../auth/application/access_controller.dart';
import '../application/organization_settings_controller.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(organizationSettingsControllerProvider).load();
    });
  }

  @override
  void dispose() {
    _userId.dispose();
    _teamName.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    final added = await ref
        .read(organizationSettingsControllerProvider)
        .addMember(_userId.text, _role);
    if (!added || !mounted) return;
    _userId.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member added to your organization.')),
    );
  }

  Future<void> _createTeam() async {
    final created = await ref
        .read(organizationSettingsControllerProvider)
        .createTeam(_teamName.text);
    if (!created || !mounted) return;
    _teamName.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team created. Add responders in Teams.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(accessControllerProvider);
    final settings = ref.watch(organizationSettingsControllerProvider);
    final isAdmin = access.context?.membership.role == MemberRole.administrator;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        Text('Organization settings', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.space8),
        Text(access.context?.organization.name ?? ''),
        const SizedBox(height: AppSpacing.space16),
        const ConnectionHelp(),
        if (!settings.canManage) ...[
          const SizedBox(height: AppSpacing.space8),
          const Text(
            'Connect before adding members or changing teams. These changes are not queued offline.',
          ),
        ],
        if (settings.loading) ...[
          const SizedBox(height: AppSpacing.space16),
          const LinearProgressIndicator(
            semanticsLabel: 'Loading organization settings',
          ),
        ],
        if (settings.error != null) ...[
          const SizedBox(height: AppSpacing.space16),
          Text(
            settings.error!,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: !settings.canManage || settings.loading || settings.busy
                ? null
                : settings.load,
            icon: const Icon(Icons.refresh),
            label: const Text('Reload workspace'),
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
        Text('Your account', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space8),
        MemberIdView(userId: access.userId?.toString()),
        const SizedBox(height: AppSpacing.space32),
        Text('Members', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space8),
        for (final member in settings.members)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: SelectableText(member.authUserId.toString()),
            subtitle: Text(memberRoleLabel(member.role)),
          ),
        if (isAdmin) ...[
          const SizedBox(height: AppSpacing.space16),
          const Text(
            'To add someone: ask them to sign in, stay on the Join a workspace screen, and copy their user ID. They should not create a separate organization. Paste their ID below and choose their role.',
          ),
          const SizedBox(height: AppSpacing.space12),
          TextField(
            controller: _userId,
            enabled: settings.canAddMember && !settings.busy,
            decoration: const InputDecoration(
              labelText: 'New member user ID',
              helperText: 'Paste their copied account ID, not your own.',
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          DropdownButtonFormField<MemberRole>(
            initialValue: _role,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(
                value: MemberRole.fieldWorker,
                child: Text(
                  'Field worker',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: MemberRole.responder,
                child: Text(
                  'Responder',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: MemberRole.coordinator,
                child: Text(
                  'Coordinator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            onChanged: !settings.canAddMember || settings.busy
                ? null
                : (role) {
                    if (role != null) setState(() => _role = role);
                  },
          ),
          const SizedBox(height: AppSpacing.space16),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'Add member',
              onPressed: !settings.canAddMember || settings.busy
                  ? null
                  : _addMember,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          const Text(
            'For reporting, choose Field worker. For assignments, choose Responder and then add that member to a team in Teams.',
          ),
        ],
        const SizedBox(height: AppSpacing.space32),
        Text('Teams', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space8),
        for (final team in settings.teams)
          ListTile(contentPadding: EdgeInsets.zero, title: Text(team.name)),
        TextField(
          controller: _teamName,
          enabled: settings.canManage && !settings.busy,
          decoration: const InputDecoration(labelText: 'New team name'),
          maxLength: 80,
        ),
        const SizedBox(height: AppSpacing.space16),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            label: 'Create team',
            onPressed: !settings.canManage || settings.busy
                ? null
                : _createTeam,
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
