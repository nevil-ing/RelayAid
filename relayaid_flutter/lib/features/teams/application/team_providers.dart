import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/connectivity/connectivity_provider.dart';
import '../../auth/application/access_controller.dart';
import '../../auth/application/client_provider.dart';
import '../data/serverpod_team_repository.dart';
import '../domain/team_repository.dart';
import 'team_controller.dart';

final teamRepositoryProvider = Provider<TeamRepository>(
  (ref) => ServerpodTeamRepository(ref.watch(serverpodClientProvider)),
);
final teamControllerProvider =
    ChangeNotifierProvider.autoDispose<TeamController>(
      (ref) => TeamController(
        repository: ref.watch(teamRepositoryProvider),
        access: ref.read(accessControllerProvider),
        connectivity: ref.read(connectivityControllerProvider),
      ),
    );
