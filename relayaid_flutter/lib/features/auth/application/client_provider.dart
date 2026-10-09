import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relayaid_client/relayaid_client.dart';

final serverpodClientProvider = Provider<Client>((ref) {
  throw StateError('Serverpod client must be provided at startup.');
});
