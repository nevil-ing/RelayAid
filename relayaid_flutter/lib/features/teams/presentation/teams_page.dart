import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../app/router/app_router.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../shared/presentation/live_feed_status_view.dart';
import '../../assignments/domain/assignment_labels.dart';
import '../../command_center/application/command_center_controller.dart';
import '../../command_center/application/command_center_providers.dart';
import '../application/team_providers.dart';

class TeamsPage extends ConsumerStatefulWidget {
  const TeamsPage({super.key});
  @override
  ConsumerState<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends ConsumerState<TeamsPage> {
  final _name = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(teamControllerProvider).loadMembers();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(commandCenterControllerProvider);
    final teams = ref.watch(teamControllerProvider);
    final enabled = feed.status == LiveFeedStatus.live && !teams.busy;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        Semantics(
          header: true,
          child: Text('Response teams', style: theme.textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.space8),
        LiveFeedStatusView(status: feed.status, onReconnect: feed.reconnect),
        const SizedBox(height: AppSpacing.space24),
        const Text(
          'Add organization responders to a team. Active response counts update live; teams may handle more than one incident.',
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.settings),
          child: const Text('Add organization members in Settings'),
        ),
        if (teams.error != null) ...[
          Text(teams.error!, style: TextStyle(color: theme.colorScheme.error)),
          TextButton(
            onPressed: teams.loadMembers,
            child: const Text('Reload responders'),
          ),
        ],
        const SizedBox(height: AppSpacing.space24),
        if (feed.feed == null || teams.loading)
          const LinearProgressIndicator(
            semanticsLabel: 'Loading teams and responders',
          ),
        for (final roster in feed.teams) ...[
          _RosterSection(
            key: ValueKey(roster.team.id),
            roster: roster,
            candidates: teams.responders
                .where(
                  (m) => !roster.responders.any(
                    (existing) => existing.authUserId == m.authUserId,
                  ),
                )
                .toList(),
            enabled: enabled,
            onAdd: (id) => teams.addResponder(roster.team.id!, id),
          ),
          const SizedBox(height: AppSpacing.space24),
          const Divider(),
          const SizedBox(height: AppSpacing.space24),
        ],
        Text('Create team', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space12),
        TextField(
          key: const ValueKey('new-team-name'),
          controller: _name,
          maxLength: 80,
          enabled: enabled,
          decoration: const InputDecoration(
            labelText: 'Team name',
            hintText: 'Team Alpha',
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            key: const ValueKey('create-team-submit'),
            onPressed: !enabled
                ? null
                : () async {
                    if (await teams.create(_name.text) && mounted) {
                      _name.clear();
                    }
                  },
            child: Text(teams.busy ? 'Saving…' : 'Create team'),
          ),
        ),
      ],
    );
  }
}

class _RosterSection extends StatefulWidget {
  const _RosterSection({
    required this.roster,
    required this.candidates,
    required this.enabled,
    required this.onAdd,
    super.key,
  });
  final TeamRoster roster;
  final List<OrganizationMember> candidates;
  final bool enabled;
  final Future<bool> Function(UuidValue) onAdd;
  @override
  State<_RosterSection> createState() => _RosterSectionState();
}

class _RosterSectionState extends State<_RosterSection> {
  UuidValue? _selected;
  @override
  Widget build(BuildContext context) {
    final roster = widget.roster;
    final selected = widget.candidates.any((m) => m.authUserId == _selected)
        ? _selected
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(roster.team.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space4),
        Text(
          '${roster.activeAssignments} active assignments · ${roster.responders.length} responder${roster.responders.length == 1 ? '' : 's'}',
        ),
        const SizedBox(height: AppSpacing.space12),
        for (final member in roster.responders)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space8),
            child: SelectableText(member.authUserId.toString()),
          ),
        if (roster.responders.isEmpty)
          const Text('Not ready for assignment: add a responder.'),
        if (widget.candidates.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space12),
          DropdownButtonFormField<UuidValue>(
            key: ValueKey(
              '${roster.team.id}:$selected:${widget.candidates.length}',
            ),
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Organization responder',
            ),
            items: [
              for (final member in widget.candidates)
                DropdownMenuItem(
                  value: member.authUserId,
                  child: Text(responderLabel(member.authUserId)),
                ),
            ],
            onChanged: !widget.enabled
                ? null
                : (id) => setState(() => _selected = id),
          ),
          const SizedBox(height: AppSpacing.space12),
          OutlinedButton(
            onPressed: !widget.enabled || selected == null
                ? null
                : () async {
                    if (await widget.onAdd(selected) && mounted) {
                      setState(() => _selected = null);
                    }
                  },
            child: const Text('Add to team'),
          ),
        ],
      ],
    );
  }
}
