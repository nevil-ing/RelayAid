import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_controller.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';

void main() {
  late _ConnectionSource source;
  late ConnectivityController controller;
  setUp(() {
    source = _ConnectionSource();
    controller = ConnectivityController(source: source);
  });
  tearDown(() async {
    controller.dispose();
    await source.events.close();
  });

  test(
    'manual check recovers a missed network change without inventing server health',
    () async {
      await controller.start();
      expect(controller.status, ConnectivityStatus.offline);
      source.current = [ConnectivityResult.wifi];
      await controller.refresh();
      expect(controller.isOnline, isTrue);
      expect(controller.isChecking, isFalse);
      expect(source.checks, 2);
    },
  );

  test('a newer platform event wins over an old in-flight check', () async {
    final gate = Completer<List<ConnectivityResult>>();
    source.gate = gate;
    final check = controller.start();
    expect(controller.isChecking, isTrue);
    source.events.add([ConnectivityResult.mobile]);
    gate.complete([ConnectivityResult.none]);
    await check;
    expect(controller.status, ConnectivityStatus.connected);
    expect(controller.isChecking, isFalse);
  });

  test(
    'platform errors finish checking with a recoverable unavailable state',
    () async {
      source.failure = StateError('private plugin details');
      await controller.start();
      expect(controller.status, ConnectivityStatus.unavailable);
      expect(controller.isChecking, isFalse);
      source.failure = null;
      source.current = [ConnectivityResult.wifi];
      await controller.refresh();
      source.events.addError(StateError('private stream details'));
      expect(controller.status, ConnectivityStatus.unavailable);
    },
  );

  test('late check results do not notify a disposed controller', () async {
    final gate = Completer<List<ConnectivityResult>>();
    source.gate = gate;
    final check = controller.refresh();
    final late = ConnectivityController(source: source);
    final lateCheck = late.refresh();
    late.dispose();
    gate.complete([ConnectivityResult.wifi]);
    await Future.wait([check, lateCheck]);
    expect(controller.status, ConnectivityStatus.connected);
  });
}

class _ConnectionSource implements ConnectivitySource {
  final events = StreamController<List<ConnectivityResult>>.broadcast(
    sync: true,
  );
  List<ConnectivityResult> current = [ConnectivityResult.none];
  Completer<List<ConnectivityResult>>? gate;
  Object? failure;
  int checks = 0;
  @override
  Stream<List<ConnectivityResult>> get changes => events.stream;
  @override
  Future<List<ConnectivityResult>> check() async {
    checks++;
    if (failure != null) throw failure!;
    return gate?.future ?? current;
  }
}
