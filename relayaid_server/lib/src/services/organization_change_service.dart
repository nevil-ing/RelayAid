import 'package:serverpod/serverpod.dart';

/// Internal commit notifications, never a client-visible authorization grant.
/// Subscribers re-read and authorize their own database snapshots.
abstract final class OrganizationChangeService {
  static String _channel(UuidValue organizationId) =>
      'relayaid.incidents.$organizationId';

  static Stream<SerializableModel> watch(
    Session session,
    UuidValue organizationId,
  ) => session.messages.createStream<SerializableModel>(
    _channel(organizationId),
  );

  static Future<void> publish(
    Session session,
    UuidValue organizationId,
    SerializableModel change,
  ) async {
    try {
      final delivered = await session.messages.postMessage(
        _channel(organizationId),
        change,
      );
      if (!delivered) {
        session.log(
          'Organization change notification was not delivered.',
          level: LogLevel.warning,
        );
      }
    } catch (_) {
      // A committed write is still successful; reconnect snapshots recover it.
      session.log(
        'Organization change notification failed after commit.',
        level: LogLevel.warning,
      );
    }
  }
}
