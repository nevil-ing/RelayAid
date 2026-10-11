import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/connectivity/connectivity_provider.dart';
import '../../core/connectivity/connectivity_status.dart';
import '../../design_system/tokens/app_spacing.dart';

/// Recovery guidance for a missing device connection, not a server health check.
class ConnectionHelp extends ConsumerWidget {
  const ConnectionHelp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectivityControllerProvider);
    if (connection.isOnline) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          connection.status == ConnectivityStatus.offline
              ? 'No network connection detected. Turn on Wi-Fi or mobile data, then check again.'
              : 'Network status is unavailable. Check your connection and try again.',
        ),
        const SizedBox(height: AppSpacing.space8),
        const Text(
          kIsWeb
              ? 'You can report in this tab. Keep it open until reports and photos synchronize.'
              : 'You can still report. Reports and photos are saved on this device until a connection is available.',
        ),
        TextButton.icon(
          onPressed: connection.isChecking
              ? null
              : () => unawaited(connection.refresh()),
          icon: const Icon(Icons.refresh),
          label: Text(
            connection.isChecking ? 'Checking connection…' : 'Check connection',
          ),
        ),
      ],
    );
  }
}
