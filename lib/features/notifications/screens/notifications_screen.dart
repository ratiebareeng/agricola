import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/notifications/models/app_notification.dart';
import 'package:agricola/features/notifications/providers/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(t('notifications', currentLang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(currentLang)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _NotificationCard(notification: notifications[index]),
            ),
    );
  }

  Widget _buildEmptyState(AppLanguage lang) {
    final isEn = lang == AppLanguage.english;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isEn ? 'No notifications' : 'Ga go na dikitsiso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEn
                  ? 'Harvest reminders and stock alerts will appear here.'
                  : 'Dikgopotso tsa go roba le ditlhagiso tsa setoko di tla bonala fano.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final config = _typeConfig(notification.type, notification.priority);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: notification.priority == NotificationPriority.high
            ? Border.all(color: config.color.withAlpha(60), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(config.icon, color: config.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (notification.priority == NotificationPriority.high)
                      Text(
                      config.priorityLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: config.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTimeAgo(notification.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static ({IconData icon, Color color, String priorityLabel}) _typeConfig(
    NotificationType type,
    NotificationPriority priority,
  ) {
    final color = switch (priority) {
      NotificationPriority.high => AppColors.alertRed,
      NotificationPriority.medium => AppColors.warmYellow,
      NotificationPriority.low => AppColors.green,
    };
    final icon = switch (type) {
      NotificationType.harvestReminder => Icons.agriculture,
      NotificationType.lowStock => Icons.warning_amber_rounded,
      NotificationType.newListing => Icons.store,
      NotificationType.general => Icons.info_outline,
    };
    final label = switch (priority) {
      NotificationPriority.high => 'Urgent',
      NotificationPriority.medium => '',
      NotificationPriority.low => '',
    };
    return (icon: icon, color: color, priorityLabel: label);
  }

  static String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.isNegative) {
      final futureDays = diff.inDays.abs();
      if (futureDays == 0) return 'Today';
      return 'In $futureDays day${futureDays == 1 ? '' : 's'}';
    }
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
