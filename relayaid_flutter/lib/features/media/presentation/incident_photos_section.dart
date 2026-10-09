import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';
import '../../../core/connectivity/connectivity_provider.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../application/media_providers.dart';
import '../domain/queued_attachment.dart';
import 'photo_tile.dart';

class IncidentPhotosSection extends ConsumerWidget {
  const IncidentPhotosSection({required this.incidentId, super.key});
  final UuidValue incidentId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(incidentPhotosProvider(incidentId));
    final online = ref.watch(connectivityControllerProvider).isOnline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space12),
        if (photos.loading)
          const Text('Loading photos…')
        else if (photos.photos.isEmpty)
          const Text('No photos attached.')
        else
          for (final photo in photos.photos) PhotoTile(photo: photo),
        if (photos.error != null) Text(photos.error!),
        if (photos.photos.any((p) => p.state != AttachmentUploadState.uploaded))
          OutlinedButton.icon(
            onPressed: !online || photos.retrying ? null : photos.retry,
            icon: const Icon(Icons.refresh),
            label: Text(
              online
                  ? 'Retry photo uploads'
                  : 'Photos saved · waiting for connection',
            ),
          ),
      ],
    );
  }
}
