import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/connectivity/connectivity_provider.dart';
import '../../auth/application/access_controller.dart';
import '../../auth/application/client_provider.dart';
import '../data/serverpod_command_center_repository.dart';
import '../domain/command_center_repository.dart';
import 'command_center_controller.dart';

final commandCenterRepositoryProvider = Provider<CommandCenterRepository>(
  (ref) => ServerpodCommandCenterRepository(ref.watch(serverpodClientProvider)),
);

final commandCenterControllerProvider =
    ChangeNotifierProvider.autoDispose<CommandCenterController>((ref) {
      return CommandCenterController(
        repository: ref.watch(commandCenterRepositoryProvider),
        access: ref.read(accessControllerProvider),
        connectivity: ref.read(connectivityControllerProvider),
      )..start();
    });
