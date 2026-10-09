import 'dart:convert';
import 'dart:io';

import 'package:relayaid_client/relayaid_client.dart';

/// Read-only release smoke check. Never signs in, creates data or uploads files.
Future<void> main(List<String> arguments) async {
  final http = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  Client? client;
  try {
    final api = _origin(
      arguments.isEmpty
          ? 'https://relayaid.api.serverpod.space/'
          : arguments.first,
    );
    final web = _origin(
      arguments.length < 2 ? 'https://relayaid.serverpod.space/' : arguments[1],
    );
    final health = await _read(http, api);
    if (!health.startsWith('OK')) {
      throw StateError('The API did not return Serverpod health feedback.');
    }
    stdout.writeln('PASS: HTTPS API health');

    final config = jsonDecode(
      await _read(http, web.resolve('assets/assets/config.json')),
    );
    final configuredApi = config is Map && config['apiUrl'] is String
        ? _origin(config['apiUrl'] as String)
        : null;
    if (configuredApi?.origin != api.origin) {
      throw StateError('The web runtime points to a different API.');
    }
    stdout.writeln('PASS: web runtime configuration matches the API');

    final page = await _read(http, web);
    if (!page.contains('<title>RelayAid') ||
        !page.contains('flutter_bootstrap.js')) {
      throw StateError('The web host is not serving the RelayAid Flutter app.');
    }
    stdout.writeln('PASS: RelayAid Flutter web host');

    client = Client(api.toString());
    await _requiresAuthentication(() async {
      await client!.organization.myContext();
    });
    await _requiresAuthentication(() async {
      await client!.incident.list(limit: 1);
    });
    stdout.writeln(
      'PASS: typed organization/incident APIs reject anonymous access',
    );
    stdout.writeln(
      'Read-only checks passed. Real sign-in, cookies, uploads, streams and '
      'physical-device acceptance still require the owner rehearsal.',
    );
  } catch (error) {
    final reason = error is StateError
        ? error.message
        : 'A configuration, TLS or network check failed.';
    stderr.writeln('Backend check failed: $reason');
    exitCode = 1;
  } finally {
    client?.close();
    http.close(force: true);
  }
}

Uri _origin(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      !{'', '/'}.contains(uri.path)) {
    throw StateError('Use a public HTTPS API/web origin without credentials.');
  }
  return uri.replace(path: '/');
}

Future<String> _read(HttpClient http, Uri uri) async {
  final request = await http.getUrl(uri).timeout(const Duration(seconds: 15));
  final response = await request.close().timeout(const Duration(seconds: 15));
  if (response.statusCode != HttpStatus.ok) {
    await response.drain<void>();
    throw StateError('A public endpoint returned HTTP ${response.statusCode}.');
  }
  return response
      .transform(utf8.decoder)
      .join()
      .timeout(const Duration(seconds: 15));
}

Future<void> _requiresAuthentication(Future<void> Function() read) async {
  try {
    await read().timeout(const Duration(seconds: 15));
  } on ServerpodClientUnauthorized {
    return;
  }
  throw StateError('A protected endpoint did not require authentication.');
}
