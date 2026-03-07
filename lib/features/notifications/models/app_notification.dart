enum NotificationType { harvestReminder, lowStock, newListing, general }

enum NotificationPriority { low, medium, high }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.medium,
    required this.createdAt,
    this.actionRoute,
  });
}
