import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_helper.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.getForUser(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () async {
                await notifProvider.markAllAsRead(user.id);
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _NotificationTile(
                  notification: notifications[index],
                  onTap: () async {
                    if (!notifications[index].isRead) {
                      await notifProvider.markAsRead(notifications[index].id);
                    }
                  },
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconAndColor(notification.type);

    return Card(
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.grey.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(
                color: color.withValues(alpha: 0.3),
              ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateHelper.timeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _iconAndColor(String type) {
    switch (type) {
      case AppConstants.notifApproved:
        return (Icons.check_circle_outline, AppColors.approved);
      case AppConstants.notifRejected:
        return (Icons.cancel_outlined, AppColors.rejected);
      case AppConstants.notifNewRequest:
        return (Icons.inbox_outlined, AppColors.pending);
      default:
        return (Icons.notifications_outlined, AppColors.primary);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
