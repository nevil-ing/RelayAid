import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/connectivity/connectivity_provider.dart';
import '../../auth/application/access_controller.dart';
import '../../auth/application/client_provider.dart';
import '../data/serverpod_assignment_repository.dart';
import '../domain/assignment_repository.dart';
import 'assignment_controller.dart';

final assignmentRepositoryProvider = Provider<AssignmentRepository>(
  (ref) => ServerpodAssignmentRepository(ref.watch(serverpodClientProvider)),
);
final assignmentControllerProvider =
    ChangeNotifierProvider.autoDispose<AssignmentController>((ref) {
      return AssignmentController(
        repository: ref.watch(assignmentRepositoryProvider),
        access: ref.read(accessControllerProvider),
        connectivity: ref.read(connectivityControllerProvider),
      )..start();
    });
