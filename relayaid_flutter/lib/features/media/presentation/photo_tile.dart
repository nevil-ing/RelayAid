import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/tokens/app_media.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../application/media_providers.dart';
import '../domain/queued_attachment.dart';

class PhotoTile extends ConsumerWidget {
  const PhotoTile({required this.photo, this.onRemove, super.key});
  final QueuedAttachment photo;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(photoBytesProvider(photo));
    final status = switch (photo.state) {
      AttachmentUploadState.draft => 'Saved with this report',
      AttachmentUploadState.pending => 'Waiting to upload',
      AttachmentUploadState.uploading => 'Uploading photo',
      AttachmentUploadState.uploaded => 'Uploaded',
      AttachmentUploadState.failed => 'Upload failed · retry available',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Incident photo. $status',
            button: true,
            child: InkWell(
              onTap: bytes.hasValue
                  ? () => showDialog<void>(
                      context: context,
                      builder: (context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.memory(
                                bytes.requireValue,
                                height: AppMedia.preview,
                                fit: BoxFit.contain,
                                semanticLabel: 'Incident evidence photo',
                              ),
                              const SizedBox(height: AppSpacing.space12),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close photo'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : null,
              child: ClipRRect(
                borderRadius: AppRadii.small,
                child: SizedBox.square(
                  dimension: AppMedia.thumbnail,
                  child: bytes.when(
                    data: (value) => Image.memory(
                      value,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Loading photo',
                      ),
                    ),
                    error: (_, _) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  '${(photo.byteLength / 1024).ceil()} KB',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (photo.error != null) Text(photo.error!),
                if (bytes.hasError)
                  const Text('Preview unavailable. Your report remains saved.'),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: 'Remove photo',
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }
}
