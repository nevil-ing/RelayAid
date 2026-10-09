import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/storage/relayaid_local_database.dart';
import 'package:relayaid_flutter/features/incidents/data/incident_local_store.dart';
import 'package:relayaid_flutter/features/incidents/domain/incident_sync_state.dart';

void main() {
  test(
    'SQLite store preserves a pending report across database reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'relayaid_phase4_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final databasePath = path.join(directory.path, 'relayaid.sqlite');
      final organizationId = UuidValue.fromString(
        '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f201',
      );
      final userId = UuidValue.fromString(
        '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f202',
      );
      final incidentId = UuidValue.fromString(
        '0199f2e9-9a4a-7e00-9a1f-4a6be0a1f203',
      );
      final incident = Incident(
        id: incidentId,
        organizationId: organizationId,
        type: IncidentType.infrastructure,
        severity: IncidentSeverity.moderate,
        status: IncidentStatus.reported,
        title: 'Blocked road',
        description: 'Debris is blocking the access road.',
        peopleAffected: 0,
        reportedBy: userId,
      );
      final detail = IncidentDetail(
        incident: incident,
        timeline: [
          IncidentEvent(
            incidentId: incidentId,
            organizationId: organizationId,
            eventType: IncidentEventType.created,
            actorId: userId,
            toStatus: IncidentStatus.reported,
          ),
        ],
      );

      final firstDatabase = await RelayAidLocalDatabase.openAt(databasePath);
      final firstStore = SqliteIncidentLocalStore(firstDatabase);
      await firstStore.save(
        LocalIncidentRecord(
          detail: detail,
          syncState: IncidentSyncState.pending,
        ),
      );
      await firstStore.close();

      final reopenedDatabase = await RelayAidLocalDatabase.openAt(databasePath);
      final reopenedStore = SqliteIncidentLocalStore(reopenedDatabase);
      final records = await reopenedStore.list(organizationId);

      expect(records, hasLength(1));
      expect(records.single.detail.incident.id, incidentId);
      expect(records.single.syncState, IncidentSyncState.pending);
      await reopenedStore.close();
    },
  );
}
