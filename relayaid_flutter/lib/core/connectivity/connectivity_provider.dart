import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import 'connectivity_controller.dart';

final connectivityControllerProvider =
    ChangeNotifierProvider<ConnectivityController>((ref) {
      final controller = ConnectivityController();
      unawaited(controller.start());
      return controller;
    });
