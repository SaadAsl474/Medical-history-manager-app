import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/sync_manager.dart';

class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final VoidCallback? onTap;

  const SyncStatusBadge({
    super.key,
    required this.status,
    this.lastSyncTime,
    this.onTap,
  });

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return 'Never synced';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    Color textColor;
    IconData iconData;
    String label;

    switch (status) {
      case SyncStatus.syncing:
        bgColor = AppColors.primaryFixed;
        iconColor = AppColors.primary;
        textColor = AppColors.primary;
        iconData = Icons.sync;
        label = 'Syncing Drive...';
        break;
      case SyncStatus.offline:
        bgColor = AppColors.surfaceContainerHigh;
        iconColor = AppColors.offlineWarning;
        textColor = AppColors.onSurfaceVariant;
        iconData = Icons.cloud_off_rounded;
        label = 'Offline Mode (Local)';
        break;
      case SyncStatus.error:
        bgColor = AppColors.errorContainer;
        iconColor = AppColors.error;
        textColor = AppColors.onErrorContainer;
        iconData = Icons.error_outline_rounded;
        label = 'Sync Failed';
        break;
      case SyncStatus.synced:
      case SyncStatus.idle:
        bgColor = AppColors.surfaceContainer;
        iconColor = AppColors.tertiaryContainer;
        textColor = AppColors.onSurface;
        iconData = Icons.check_circle_rounded;
        label = 'Drive Synced ${_formatTimeAgo(lastSyncTime)}';
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            status == SyncStatus.syncing
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                : Icon(
                    iconData,
                    size: 15,
                    color: iconColor,
                  ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
