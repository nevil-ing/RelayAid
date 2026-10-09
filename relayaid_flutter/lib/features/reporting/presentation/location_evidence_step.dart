import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/location/location_service.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../media/presentation/photo_draft_section.dart';
import '../domain/report_validation.dart';

class LocationEvidenceStep extends ConsumerStatefulWidget {
  const LocationEvidenceStep({
    required this.latitude,
    required this.longitude,
    super.key,
  });

  final TextEditingController latitude;
  final TextEditingController longitude;

  @override
  ConsumerState<LocationEvidenceStep> createState() =>
      _LocationEvidenceStepState();
}

class _LocationEvidenceStepState extends ConsumerState<LocationEvidenceStep> {
  LocationFix? _captured;

  Future<void> _locate() async {
    FocusScope.of(context).unfocus();
    final fix = await ref.read(locationControllerProvider).locate();
    if (!mounted || fix == null) return;
    setState(() {
      _captured = fix;
      widget.latitude.text = fix.latitude.toStringAsFixed(6);
      widget.longitude.text = fix.longitude.toStringAsFixed(6);
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationControllerProvider);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Where is it?', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space8),
        const Text(
          'Use your position if you are at the incident. Otherwise enter its coordinates. Location is optional; GPS can work without internet.',
        ),
        const SizedBox(height: AppSpacing.space16),
        OutlinedButton.icon(
          onPressed: location.busy ? null : _locate,
          icon: Icon(location.busy ? Icons.hourglass_top : Icons.my_location),
          label: Text(
            location.busy ? 'Finding location…' : 'Use current location',
          ),
        ),
        if (_captured != null) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Location captured · accuracy about ${_captured!.accuracyMeters.ceil()} m. Check the coordinates before saving.',
          ),
        ],
        if (location.message != null) ...[
          const SizedBox(height: AppSpacing.space8),
          Semantics(liveRegion: true, child: Text(location.message!)),
          if (location.problem == LocationProblem.blocked ||
              location.problem == LocationProblem.disabled)
            TextButton.icon(
              onPressed: location.openSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open location settings'),
            ),
        ],
        const SizedBox(height: AppSpacing.space16),
        TextFormField(
          controller: widget.latitude,
          enabled: !location.busy,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Latitude'),
          onChanged: (_) => setState(() => _captured = null),
          validator: (value) => ReportValidation.coordinate(
            value,
            latitude: true,
            other: widget.longitude.text,
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        TextFormField(
          controller: widget.longitude,
          enabled: !location.busy,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Longitude'),
          onChanged: (_) => setState(() => _captured = null),
          validator: (value) => ReportValidation.coordinate(
            value,
            latitude: false,
            other: widget.latitude.text,
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
        const PhotoDraftSection(),
      ],
    );
  }
}
