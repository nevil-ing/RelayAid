import 'dart:async';
import 'dart:typed_data';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_controller.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/incidents/data/incident_local_store.dart';
import 'package:relayaid_flutter/features/incidents/data/local_first_incident_repository.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_repository.dart';
import 'package:relayaid_flutter/features/media/data/attachment_local_store.dart';
import 'package:relayaid_flutter/features/media/data/local_attachment_repository.dart';
import 'package:relayaid_flutter/features/media/data/photo_file_store_memory.dart';
import 'package:relayaid_flutter/features/media/domain/attachment_repository.dart';
import 'package:relayaid_flutter/features/media/domain/queued_attachment.dart';

final testPhotoBytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0]);

class MediaFixture {
  MediaFixture({
    IncidentLocalStore? incidentStore,
    AttachmentLocalStore? attachmentStore,
    PhotoFileStore? files,
  }) {
    this.incidentStore = incidentStore ?? MemoryIncidentLocalStore();
    store = attachmentStore ?? MemoryAttachmentLocalStore();
    connectivity.setStatusForTest(ConnectivityStatus.offline);
    context = OrganizationContext(
      organization: Organization(
        id: organizationId,
        name: 'Response',
        createdBy: userId,
      ),
      membership: OrganizationMember(
        organizationId: organizationId,
        authUserId: userId,
        role: MemberRole.fieldWorker,
      ),
    );
    incidents = LocalFirstIncidentRepository(
      remote: incidentRemote,
      localStore: this.incidentStore,
      connectivity: connectivity,
      readOrganizationContext: () async => context,
    );
    attachments = LocalAttachmentRepository(
      store: store,
      files: files ?? MemoryPhotoFileStore(),
      picker: picker,
      remote: remote,
      incidents: this.incidentStore,
      incidentSync: incidents,
      connectivity: connectivity,
      readContext: () => context,
      now: () => time,
    );
  }
  final organizationId = UuidValue.fromString(
    '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f101',
  );
  final userId = UuidValue.fromString('0199f2e9-9a4a-7e00-9a1f-4a6be0a1f102');
  OrganizationContext? context;
  final connectivity = ConnectivityController();
  final picker = FakePhotoPicker();
  final remote = FakeAttachmentRemote();
  final incidentRemote = FakeIncidentRemote();
  late final IncidentLocalStore incidentStore;
  late final AttachmentLocalStore store;
  late final LocalFirstIncidentRepository incidents;
  late final LocalAttachmentRepository attachments;
  DateTime time = DateTime.utc(2026, 9, 29);

  Future<IncidentDetail> report(UuidValue id) => incidents.create(
    id: id,
    type: IncidentType.flooding,
    severity: IncidentSeverity.high,
    title: 'Flooded bridge',
    description: 'Water has blocked the road.',
    latitude: -0.3,
    longitude: 36.08,
    peopleAffected: 12,
  );
  Future<void> dispose({bool ownsConnectivity = true}) async {
    await attachments.dispose();
    await incidents.dispose();
    if (ownsConnectivity) connectivity.dispose();
  }
}

class FakePhotoPicker implements PhotoPicker {
  Uint8List? bytes = testPhotoBytes;
  Uint8List? recovered;
  @override
  bool get supportsCamera => false;
  @override
  Future<Uint8List?> pick(PhotoSource source) async => bytes;
  @override
  Future<Uint8List?> recover() async => recovered;
}

class FakeAttachmentRemote implements AttachmentRemote {
  int calls = 0;
  int failures = 0;
  AttachmentValidationException? rejection;
  final uploaded = <UuidValue, IncidentAttachment>{};
  @override
  Future<IncidentAttachment> upload(
    QueuedAttachment photo,
    Uint8List bytes,
  ) async {
    calls++;
    if (rejection != null) throw rejection!;
    if (failures > 0) {
      failures--;
      throw StateError('temporary network failure');
    }
    return uploaded.putIfAbsent(
      photo.id,
      () => IncidentAttachment(
        id: photo.id,
        incidentId: photo.incidentId,
        organizationId: photo.organizationId,
        uploadedBy: photo.userId,
        contentType: photo.contentType,
        byteLength: bytes.length,
      ),
    );
  }

  @override
  Future<List<IncidentAttachment>> list(UuidValue id) async =>
      uploaded.values.where((p) => p.incidentId == id).toList();
  @override
  Future<Uint8List> read(UuidValue id) async => testPhotoBytes;
}

class FakeIncidentRemote implements IncidentRepository {
  int calls = 0;
  int failures = 0;
  Completer<void>? gate;
  final firstStarted = Completer<void>();
  @override
  Future<IncidentDetail> create({
    UuidValue? id,
    required IncidentType type,
    required IncidentSeverity severity,
    required String title,
    required String description,
    required double? latitude,
    required double? longitude,
    required int peopleAffected,
  }) async {
    calls++;
    if (!firstStarted.isCompleted) firstStarted.complete();
    await gate?.future;
    if (failures > 0) {
      failures--;
      throw StateError('metadata sync failed');
    }
    return IncidentDetail(
      incident: Incident(
        id: id,
        organizationId: UuidValue.fromString(
          '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f101',
        ),
        reportedBy: UuidValue.fromString(
          '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f102',
        ),
        type: type,
        severity: severity,
        status: IncidentStatus.reported,
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        peopleAffected: peopleAffected,
      ),
      timeline: [],
    );
  }

  @override
  Future<List<Incident>> list({int limit = 50}) async => [];
  @override
  Future<IncidentDetail> detail(UuidValue id) => throw UnimplementedError();
  @override
  Future<IncidentDetail> transition(
    UuidValue id,
    IncidentStatus status, {
    String? note,
  }) => throw UnimplementedError();
}
