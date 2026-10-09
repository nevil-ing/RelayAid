import 'package:relayaid_client/relayaid_client.dart';

String memberRoleLabel(MemberRole role) => switch (role) {
  MemberRole.fieldWorker => 'Field worker',
  MemberRole.responder => 'Responder',
  MemberRole.coordinator => 'Coordinator',
  MemberRole.administrator => 'Administrator',
};
