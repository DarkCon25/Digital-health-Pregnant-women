import 'package:flutter/material.dart';

import '../../core/nurse_colors.dart';

class PatientQuickActions extends StatelessWidget {
  const PatientQuickActions({
    super.key,
    this.onMonitor,
    this.onMessage,
    this.onDetails,
  });

  final VoidCallback? onMonitor;
  final VoidCallback? onMessage;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Monitor',
          onPressed: onMonitor,
          icon: const Icon(Icons.monitor_heart_outlined),
          color: NurseColors.primary,
        ),
        IconButton(
          tooltip: 'Message',
          onPressed: onMessage,
          icon: const Icon(Icons.chat_bubble_outline),
          color: NurseColors.accentBlue,
        ),
        IconButton(
          tooltip: 'Details',
          onPressed: onDetails,
          icon: const Icon(Icons.info_outline),
          color: NurseColors.textSecondary,
        ),
      ],
    );
  }
}
