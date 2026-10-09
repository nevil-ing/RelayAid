import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:relayaid_client/relayaid_client.dart';
import '../domain/attachment_repository.dart';

Future<PhotoFileStore> createPhotoFileStore() async {
  final support = await getApplicationSupportDirectory();
  return NativePhotoFileStore(path.join(support.path, 'incident_photos'));
}

class NativePhotoFileStore implements PhotoFileStore {
  NativePhotoFileStore(this.directoryPath);
  final String directoryPath;

  @override
  Future<String> save(UuidValue id, Uint8List bytes) async {
    await Directory(directoryPath).create(recursive: true);
    final filename = '${id.toString()}.photo';
    final temporary = File(path.join(directoryPath, '$filename.tmp'));
    await temporary.writeAsBytes(bytes, flush: true);
    await temporary.rename(path.join(directoryPath, filename));
    // Relative references survive iOS sandbox-directory changes.
    return filename;
  }

  File _file(String filename) {
    if (path.basename(filename) != filename || !filename.endsWith('.photo')) {
      throw const PhotoFailure('This photo cannot be opened.');
    }
    return File(path.join(directoryPath, filename));
  }

  @override
  Future<Uint8List> read(String path) => _file(path).readAsBytes();
  @override
  Future<void> remove(String path) async {
    final file = _file(path);
    if (await file.exists()) await file.delete();
  }
}
