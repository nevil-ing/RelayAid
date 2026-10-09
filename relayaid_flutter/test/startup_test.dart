import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_flutter/app/startup_page.dart';
import 'package:relayaid_flutter/core/network/backend_configuration.dart';

void main() {
  test('release builds accept the HTTPS Cloud URL and normalize its slash', () {
    expect(
      BackendConfiguration.validate(
        'https://relayaid.api.serverpod.space',
        release: true,
      ),
      'https://relayaid.api.serverpod.space/',
    );
    expect(
      BackendConfiguration.validate('http://localhost:8080', release: false),
      'http://localhost:8080/',
    );
  });

  test(
    'release config rejects localhost, insecure, malformed and secret-bearing URLs',
    () {
      for (final value in [
        'http://relayaid.api.serverpod.space/',
        'https://localhost/',
        'https://127.0.0.1/',
        'https://[::1]/',
        'https://0.0.0.0/',
        'https://x.localhost/',
        'not a server',
        'https://',
        'https://user:password@example.com/',
        'https://example.com/?key=private',
        'https://example.com/#token',
      ]) {
        expect(
          () => BackendConfiguration.validate(value, release: true),
          throwsA(isA<BackendConfigurationFailure>()),
          reason: value,
        );
      }
    },
  );

  testWidgets('startup shows loading and then the initialized workspace', (
    tester,
  ) async {
    final initialized = Completer<Widget>();
    await tester.pumpWidget(
      RelayAidStartup(initialize: () => initialized.future),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    initialized.complete(const MaterialApp(home: Text('Ready workspace')));
    await tester.pumpAndSettle();
    expect(find.text('Ready workspace'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'startup failure keeps a safe retry action without raw diagnostics',
    (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        RelayAidStartup(
          initialize: () async {
            if (++attempts == 1) {
              throw StateError('private path and native diagnostic');
            }
            return const MaterialApp(home: Text('Recovered workspace'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('saved reports have not been erased'),
        findsOneWidget,
      );
      expect(find.textContaining('private path'), findsNothing);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Recovered workspace'), findsOneWidget);
      expect(attempts, 2);
    },
  );

  testWidgets('bad backend configuration has a clear release error', (
    tester,
  ) async {
    await tester.pumpWidget(
      RelayAidStartup(
        initialize: () async => throw const BackendConfigurationFailure(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('valid secure server address'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
