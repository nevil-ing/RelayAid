import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../application/media_providers.dart';
import '../domain/attachment_repository.dart';
import 'photo_tile.dart';

class PhotoDraftSection extends ConsumerWidget {
  const PhotoDraftSection({this.disabled = false, super.key});
  final bool disabled;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(photoDraftControllerProvider);
    final picker = ref.watch(photoPickerProvider);
    final canAdd = !disabled && !draft.busy && draft.photos.length < 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.space8),
        const Text(
          kIsWeb
              ? 'Keep this tab open until photos upload. Unsent web photos do not survive a reload.'
              : 'Photos stay on this device and upload separately from the report.',
        ),
        const SizedBox(height: AppSpacing.space12),
        for (final photo in draft.photos)
          PhotoTile(
            photo: photo,
            onRemove: disabled || draft.busy
                ? null
                : () => draft.remove(photo.id),
          ),
        Wrap(
          spacing: AppSpacing.space8,
          runSpacing: AppSpacing.space8,
          children: [
            if (picker.supportsCamera)
              OutlinedButton.icon(
                onPressed: canAdd ? () => draft.pick(PhotoSource.camera) : null,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Take photo'),
              ),
            OutlinedButton.icon(
              onPressed: canAdd ? () => draft.pick(PhotoSource.library) : null,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose photo'),
            ),
          ],
        ),
        if (draft.busy)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.space8),
            child: Text('Preparing photos…'),
          ),
        if (draft.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space8),
            child: Text(
              draft.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
