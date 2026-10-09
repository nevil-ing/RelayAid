import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/connectivity/connectivity_provider.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../application/media_providers.dart';
import 'photo_tile.dart';

class AttachmentQueueSection extends ConsumerWidget {
  const AttachmentQueueSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(uploadQueueProvider);
    final online = ref.watch(connectivityControllerProvider).isOnline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo uploads', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.space12),
        if (queue.loading)
          const Text('Loading upload queue…')
        else if (queue.photos.isEmpty)
          const Text('No photos waiting to upload.')
        else ...[
          for (final photo in queue.photos) PhotoTile(photo: photo),
          OutlinedButton.icon(
            onPressed: online && !queue.retrying ? queue.retry : null,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(queue.retrying ? 'Retrying…' : 'Retry uploads now'),
          ),
        ],
        if (queue.error != null) Text(queue.error!),
      ],
    );
  }
}
