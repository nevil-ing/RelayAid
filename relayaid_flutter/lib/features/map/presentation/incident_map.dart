import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/map_configuration.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_workspace.dart';
import '../../incidents/presentation/incident_labels.dart';
import '../../command_center/domain/incident_filter.dart';

// Tests supply a local tile provider; production uses flutter_map's HTTP cache.
final mapTileProvider = Provider<TileProvider?>((ref) => null);

class IncidentMap extends ConsumerStatefulWidget {
  const IncidentMap({
    required this.incidents,
    required this.selectedId,
    required this.onSelect,
    this.configuration = const MapConfiguration(),
    super.key,
  });

  final List<Incident> incidents;
  final UuidValue? selectedId;
  final ValueChanged<UuidValue?> onSelect;
  final MapConfiguration configuration;

  @override
  ConsumerState<IncidentMap> createState() => _IncidentMapState();
}

class _IncidentMapState extends ConsumerState<IncidentMap> {
  final _map = MapController();
  bool _ready = false;
  bool _tileError = false;

  List<Incident> get _located =>
      widget.incidents.where(hasMapLocation).toList();
  LatLng _point(Incident incident) =>
      LatLng(incident.latitude!, incident.longitude!);

  @override
  void didUpdateWidget(IncidentMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusSelected());
    } else if (!oldWidget.incidents.any(hasMapLocation) &&
        _located.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    }
  }

  void _focusSelected() {
    if (!mounted || !_ready) return;
    for (final incident in _located) {
      if (incident.id == widget.selectedId) {
        _map.move(_point(incident), AppWorkspace.incidentZoom);
        return;
      }
    }
  }

  void _fit() {
    if (!mounted || !_ready || _located.isEmpty) return;
    if (_located.length == 1) {
      _map.move(_point(_located.single), AppWorkspace.incidentZoom);
    } else {
      _map.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(_located.map(_point).toList()),
          padding: const EdgeInsets.all(AppSpacing.space40),
          maxZoom: AppWorkspace.incidentZoom,
        ),
      );
    }
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final located = _located;
    return Semantics(
      label: 'Incident map, ${located.length} locations',
      container: true,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              backgroundColor: colors.surfaceContainerLow,
              initialCenter: located.isEmpty
                  ? const LatLng(
                      AppWorkspace.initialLatitude,
                      AppWorkspace.initialLongitude,
                    )
                  : _point(located.first),
              initialZoom: located.length == 1
                  ? AppWorkspace.incidentZoom
                  : AppWorkspace.initialZoom,
              initialCameraFit: located.length < 2
                  ? null
                  : CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(
                        located.map(_point).toList(),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.space40),
                      maxZoom: AppWorkspace.incidentZoom,
                    ),
              maxZoom: AppWorkspace.maxZoom,
              onMapReady: () {
                _ready = true;
                _focusSelected();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: widget.configuration.tileUrl,
                userAgentPackageName: MapConfiguration.userAgent,
                tileProvider: ref.watch(mapTileProvider),
                panBuffer: 0,
                errorTileCallback: (tile, error, stack) {
                  if (_tileError) return;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_tileError) {
                      setState(() => _tileError = true);
                    }
                  });
                },
              ),
              MarkerLayer(
                markers: [
                  for (final incident in located)
                    Marker(
                      point: _point(incident),
                      width: AppWorkspace.markerSize,
                      height: AppWorkspace.markerSize,
                      child: Semantics(
                        selected: incident.id == widget.selectedId,
                        child: IconButton(
                          key: ValueKey('incident-marker-${incident.id}'),
                          tooltip:
                              '${incident.title} · ${incidentSeverityLabel(incident.severity)} · ${incidentStatusLabel(incident.status)}',
                          onPressed: () => widget.onSelect(incident.id),
                          style: IconButton.styleFrom(
                            backgroundColor: incident.id == widget.selectedId
                                ? colors.primaryContainer
                                : colors.surface,
                            foregroundColor: _severityColor(incident.severity),
                            side: BorderSide(
                              color: incident.id == widget.selectedId
                                  ? colors.primary
                                  : colors.outline,
                            ),
                          ),
                          icon: const Icon(
                            Icons.location_on,
                            size: AppSpacing.space32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: AppSpacing.space12,
            right: AppSpacing.space12,
            child: Material(
              color: colors.surface,
              child: Column(
                children: [
                  IconButton(
                    tooltip: 'Zoom in',
                    onPressed: () => _map.move(
                      _map.camera.center,
                      (_map.camera.zoom + 1).clamp(0, AppWorkspace.maxZoom),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    tooltip: 'Zoom out',
                    onPressed: () => _map.move(
                      _map.camera.center,
                      (_map.camera.zoom - 1).clamp(0, AppWorkspace.maxZoom),
                    ),
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    tooltip: 'Fit incident locations',
                    onPressed: located.isEmpty ? null : _fit,
                    icon: const Icon(Icons.center_focus_strong),
                  ),
                ],
              ),
            ),
          ),
          if (located.isEmpty || _tileError)
            Positioned(
              top: AppSpacing.space12,
              left: AppSpacing.space12,
              right: AppWorkspace.markerSize + AppSpacing.space24,
              child: Material(
                color: colors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  child: Text(
                    located.isEmpty
                        ? 'No map locations in this view. Reports without coordinates remain in the list.'
                        : 'Some map tiles could not load. Incident locations remain available.',
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: colors.surface,
              child: TextButton(
                onPressed: () => unawaited(
                  launchUrl(Uri.parse(widget.configuration.attributionUrl)),
                ),
                child: Text('© ${widget.configuration.attribution}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _severityColor(IncidentSeverity severity) => switch (severity) {
  IncidentSeverity.critical => AppColors.danger,
  IncidentSeverity.high => AppColors.warning,
  IncidentSeverity.moderate => AppColors.info,
  IncidentSeverity.low => AppColors.success,
};
