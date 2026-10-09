import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../app/router/app_router.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_workspace.dart';
import '../../incidents/application/incident_controller.dart';
import '../../incidents/presentation/incident_list_tile.dart';
import 'incident_map.dart';

class FieldMapPage extends ConsumerStatefulWidget {
  const FieldMapPage({super.key});

  @override
  ConsumerState<FieldMapPage> createState() => _FieldMapPageState();
}

class _FieldMapPageState extends ConsumerState<FieldMapPage> {
  UuidValue? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(incidentControllerProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(incidentControllerProvider);
    final incidents = controller.incidents;
    final selected = incidents
        .where((item) => item.id == _selectedId)
        .firstOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space24,
        AppSpacing.space24,
        AppSpacing.space24,
        AppSpacing.space40,
      ),
      children: [
        Text('Incident map', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.space8),
        const Text(
          'Saved incident locations. Map tiles need a connection; coordinates and saved reports remain available offline.',
        ),
        const SizedBox(height: AppSpacing.space16),
        SizedBox(
          height: AppWorkspace.compactListHeight,
          child: IncidentMap(
            incidents: incidents,
            selectedId: _selectedId,
            onSelect: (id) => setState(() => _selectedId = id),
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.space16),
          IncidentListTile(
            incident: selected,
            syncState: controller.syncStateFor(selected.id),
            onTap: () =>
                context.go('${AppRoutes.incidentDetail}?id=${selected.id}'),
          ),
        ],
        if (controller.status == IncidentViewStatus.loading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.space16),
            child: LinearProgressIndicator(
              semanticsLabel: 'Loading saved locations',
            ),
          ),
        if (controller.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space12),
            child: Text(controller.error!),
          ),
        const SizedBox(height: AppSpacing.space12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: controller.status == IncidentViewStatus.loading
                ? null
                : controller.load,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh saved reports'),
          ),
        ),
      ],
    );
  }
}
