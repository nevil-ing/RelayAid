import 'package:flutter/material.dart';

import '../../core/network/live_feed_status.dart';
import '../../design_system/tokens/app_motion.dart';
import '../../design_system/tokens/app_spacing.dart';

class LiveFeedStatusView extends StatelessWidget {
  const LiveFeedStatusView({
    required this.status,
    required this.onReconnect,
    super.key,
  });
  final LiveFeedStatus status;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (status) {
      LiveFeedStatus.connecting => (
        Icons.hourglass_top,
        'Connecting to live updates',
      ),
      LiveFeedStatus.live => (
        Icons.check_circle_outline,
        'Live updates connected',
      ),
      LiveFeedStatus.reconnecting => (
        Icons.sync,
        'Reconnecting · showing last update',
      ),
      LiveFeedStatus.offline => (
        Icons.cloud_off_outlined,
        'Offline · showing last update',
      ),
      LiveFeedStatus.accessDenied => (
        Icons.lock_outline,
        'Organization access required',
      ),
    };
    return Wrap(
      spacing: AppSpacing.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.feedback,
          child: Row(
            key: ValueKey(status),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSpacing.space16),
              const SizedBox(width: AppSpacing.space8),
              Flexible(child: Text(label)),
            ],
          ),
        ),
        if (status == LiveFeedStatus.reconnecting ||
            status == LiveFeedStatus.accessDenied)
          TextButton(onPressed: onReconnect, child: const Text('Reconnect')),
      ],
    );
  }
}
