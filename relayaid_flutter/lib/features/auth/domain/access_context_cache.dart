import 'package:relayaid_client/relayaid_client.dart';

abstract interface class AccessContextCache {
  Future<OrganizationContext?> read(UuidValue userId);

  Future<void> write(OrganizationContext context);

  Future<void> remove(UuidValue userId);
}
