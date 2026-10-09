import 'dart:typed_data';
import 'package:relayaid_client/relayaid_client.dart';
import '../domain/attachment_repository.dart';

Future<PhotoFileStore> createPhotoFileStore() async => MemoryPhotoFileStore();

/// Web is server-first; unsent browser photos do not survive a tab reload.
class MemoryPhotoFileStore implements PhotoFileStore {
  final _files = <String, Uint8List>{};
  @override
  Future<String> save(UuidValue id, Uint8List bytes) async {
    final path = id.toString();
    _files[path] = Uint8List.fromList(bytes);
    return path;
  }

  @override
  Future<Uint8List> read(String path) async =>
      _files[path] ??
      (throw const PhotoFailure('This photo is no longer on this device.'));
  @override
  Future<void> remove(String path) async {
    _files.remove(path);
  }
}
