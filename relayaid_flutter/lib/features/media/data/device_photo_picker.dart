import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/attachment_repository.dart';

class DevicePhotoPicker implements PhotoPicker {
  final _picker = ImagePicker();

  @override
  bool get supportsCamera =>
      !kIsWeb &&
      {
        TargetPlatform.iOS,
        TargetPlatform.android,
      }.contains(defaultTargetPlatform);

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    if (await file.length() > 5 * 1024 * 1024) {
      throw const PhotoFailure('Choose a photo smaller than 5 MB.');
    }
    return file.readAsBytes();
  }

  @override
  Future<Uint8List?> recover() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    final lost = await _picker.retrieveLostData();
    final files = lost.files;
    if (files == null || files.isEmpty) return null;
    if (await files.first.length() > 5 * 1024 * 1024) {
      throw const PhotoFailure('The recovered photo exceeds 5 MB.');
    }
    return files.first.readAsBytes();
  }
}
