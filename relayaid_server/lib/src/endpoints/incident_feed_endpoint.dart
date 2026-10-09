import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/incident_feed_service.dart';

/// The organization and role are resolved by the server, never the caller.
class IncidentFeedEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Stream<IncidentFeed> watch(Session session) =>
      IncidentFeedService.watch(session);
}
