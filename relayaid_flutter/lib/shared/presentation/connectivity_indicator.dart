import 'package:flutter/material.dart';

import '../../core/connectivity/connectivity_status.dart';
import '../../design_system/components/app_status_badge.dart';

class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({
    required this.status,
    this.compact = false,
    super.key,
  });

  final ConnectivityStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final presentation = switch (status) {
      ConnectivityStatus.unavailable => (
        label: 'Connection unavailable',
        tone: AppStatusTone.neutral,
        icon: Icons.wifi_off_outlined,
      ),
      ConnectivityStatus.connected => (
        label: 'Connected',
        tone: AppStatusTone.success,
        icon: Icons.wifi_outlined,
      ),
      ConnectivityStatus.offline => (
        label: 'Offline',
        tone: AppStatusTone.warning,
        icon: Icons.cloud_off_outlined,
      ),
      ConnectivityStatus.syncing => (
        label: 'Syncing',
        tone: AppStatusTone.info,
        icon: Icons.sync,
      ),
    };

    if (compact) {
      return Tooltip(
        message: presentation.label,
        child: Semantics(
          label: 'Current status: ${presentation.label}',
          child: Icon(presentation.icon),
        ),
      );
    }
    return AppStatusBadge(
      label: presentation.label,
      tone: presentation.tone,
      icon: presentation.icon,
    );
  }
}
