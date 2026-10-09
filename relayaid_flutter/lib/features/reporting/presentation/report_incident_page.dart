import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relayaid_client/relayaid_client.dart';

import '../../../app/router/app_router.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/tokens/app_motion.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../incidents/application/incident_controller.dart';
import '../../media/application/media_providers.dart';
import 'incident_step.dart';
import 'location_evidence_step.dart';
import 'report_review_step.dart';

class ReportIncidentPage extends ConsumerStatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  ConsumerState<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends ConsumerState<ReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _peopleAffected = TextEditingController(text: '0');
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  IncidentType _type = IncidentType.flooding;
  IncidentSeverity _severity = IncidentSeverity.moderate;
  int _step = 0;

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _peopleAffected,
      _latitude,
      _longitude,
    ]) {
      controller.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  void _changeStep(int next) {
    FocusScope.of(context).unfocus();
    if (!kIsWeb) unawaited(HapticFeedback.selectionClick());
    setState(() => _step = next);
    _scroll.jumpTo(0);
  }

  void _continue() {
    if (_formKey.currentState?.validate() != true) return;
    _changeStep(_step + 1);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final result = await ref
        .read(incidentControllerProvider)
        .create(
          id: ref.read(photoDraftControllerProvider).incidentId,
          type: _type,
          severity: _severity,
          title: _title.text,
          description: _description.text,
          latitude: double.tryParse(_latitude.text.trim()),
          longitude: double.tryParse(_longitude.text.trim()),
          peopleAffected: int.parse(_peopleAffected.text.trim()),
        );
    if (!mounted || result?.incident.id == null) return;
    if (!kIsWeb) unawaited(HapticFeedback.lightImpact());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          kIsWeb
              ? 'Report saved in this session. Keep the tab open until synchronized.'
              : 'Report saved on this device. Photos synchronize separately.',
        ),
      ),
    );
    context.go('${AppRoutes.incidentDetail}?id=${result!.incident.id}');
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(incidentControllerProvider);
    final draft = ref.watch(photoDraftControllerProvider);
    final busy = controller.status == IncidentViewStatus.submitting;
    final theme = Theme.of(context);
    const labels = ['Incident', 'Location / evidence', 'Review'];
    return PopScope(
      canPop: _step == 0 && !busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy && _step > 0) _changeStep(_step - 1);
      },
      child: ListView(
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space24,
          AppSpacing.space24,
          AppSpacing.space24,
          AppSpacing.space40,
        ),
        children: [
          Text('Report incident', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.space12),
          Semantics(
            liveRegion: true,
            child: Text(
              'Step ${_step + 1} of 3 · ${labels[_step]}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          Form(
            key: _formKey,
            child: AbsorbPointer(
              absorbing: busy,
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppMotion.feedback,
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: switch (_step) {
                    0 => IncidentStep(
                      title: _title,
                      description: _description,
                      peopleAffected: _peopleAffected,
                      type: _type,
                      severity: _severity,
                      onTypeChanged: (value) => setState(() => _type = value),
                      onSeverityChanged: (value) =>
                          setState(() => _severity = value),
                    ),
                    1 => LocationEvidenceStep(
                      latitude: _latitude,
                      longitude: _longitude,
                    ),
                    _ => ReportReviewStep(
                      title: _title.text,
                      description: _description.text,
                      type: _type,
                      severity: _severity,
                      peopleAffected: _peopleAffected.text,
                      latitude: _latitude.text,
                      longitude: _longitude.text,
                      photoCount: draft.photos.length,
                    ),
                  },
                ),
              ),
            ),
          ),
          if (controller.status == IncidentViewStatus.error &&
              controller.error != null) ...[
            const SizedBox(height: AppSpacing.space16),
            Semantics(
              liveRegion: true,
              child: Text(
                controller.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space24),
          AppButton(
            label: _step < 2
                ? 'Continue'
                : busy
                ? 'Saving…'
                : 'Save incident',
            icon: _step < 2 ? Icons.arrow_forward : Icons.save_outlined,
            onPressed: busy || draft.busy
                ? null
                : _step < 2
                ? _continue
                : _submit,
          ),
          if (_step > 0) ...[
            const SizedBox(height: AppSpacing.space8),
            TextButton.icon(
              onPressed: busy ? null : () => _changeStep(_step - 1),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ],
        ],
      ),
    );
  }
}
