import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/features/crops/crop_helpers.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/notifications/models/app_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Derives notifications from existing crop and inventory data.
/// No backend needed — purely client-side alerts.
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final lang = ref.watch(languageProvider);
  final cropsAsync = ref.watch(cropNotifierProvider);
  final inventoryAsync = ref.watch(inventoryNotifierProvider);
  final catalog = ref.watch(cropCatalogProvider).valueOrNull ?? [];

  final notifications = <AppNotification>[];
  final now = DateTime.now();

  // Harvest reminders from crops
  final crops = cropsAsync.valueOrNull ?? [];
  for (final crop in crops) {
    final daysUntil = crop.expectedHarvestDate.difference(now).inDays;
    final name = cropDisplayName(crop.cropType, catalog, lang);

    if (daysUntil < 0 && daysUntil > -30) {
      notifications.add(_overdueHarvest(crop, name, daysUntil.abs(), lang));
    } else if (daysUntil >= 0 && daysUntil <= 7) {
      notifications.add(_upcomingHarvest(crop, name, daysUntil, lang));
    } else if (daysUntil > 7 && daysUntil <= 14) {
      notifications.add(_approachingHarvest(crop, name, daysUntil, lang));
    }
  }

  // Low stock / poor condition from inventory
  final inventory = inventoryAsync.valueOrNull ?? [];
  for (final item in inventory) {
    final itemName = cropDisplayName(item.cropType, catalog, lang);
    if (item.condition == 'critical') {
      notifications.add(_criticalCondition(item, itemName, lang));
    } else if (item.condition == 'needs_attention') {
      notifications.add(_needsAttention(item, itemName, lang));
    }
  }

  // Sort: high priority first, then by date (newest first)
  notifications.sort((a, b) {
    final priorityCompare = b.priority.index.compareTo(a.priority.index);
    if (priorityCompare != 0) return priorityCompare;
    return b.createdAt.compareTo(a.createdAt);
  });

  return notifications;
});

/// Count of high-priority notifications (for badge display)
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications
      .where((n) => n.priority == NotificationPriority.high)
      .length;
});

// ---------------------------------------------------------------------------
// Notification factory helpers
// ---------------------------------------------------------------------------

AppNotification _overdueHarvest(CropModel crop, String displayName, int daysOverdue, AppLanguage lang) {
  final isEn = lang == AppLanguage.english;
  return AppNotification(
    id: 'harvest_overdue_${crop.id}',
    title: isEn
        ? '$displayName harvest overdue'
        : '$displayName nako ya go roba e fetile',
    body: isEn
        ? '${crop.fieldName} was due $daysOverdue day${daysOverdue == 1 ? '' : 's'} ago. Record your harvest or update the crop.'
        : '${crop.fieldName} e ne e tshwanetse go robwa maloba $daysOverdue a fetile.',
    type: NotificationType.harvestReminder,
    priority: NotificationPriority.high,
    createdAt: crop.expectedHarvestDate,
  );
}

AppNotification _upcomingHarvest(CropModel crop, String displayName, int daysUntil, AppLanguage lang) {
  final isEn = lang == AppLanguage.english;
  final timeText = daysUntil == 0
      ? (isEn ? 'today' : 'gompieno')
      : (isEn
          ? 'in $daysUntil day${daysUntil == 1 ? '' : 's'}'
          : 'mo malatsing a $daysUntil');
  return AppNotification(
    id: 'harvest_soon_${crop.id}',
    title: isEn
        ? '$displayName ready $timeText'
        : '$displayName e iketleeditse $timeText',
    body: isEn
        ? '${crop.fieldName} is due for harvest $timeText. Prepare your storage.'
        : '${crop.fieldName} e tshwanetse go robwa $timeText.',
    type: NotificationType.harvestReminder,
    priority: daysUntil <= 2
        ? NotificationPriority.high
        : NotificationPriority.medium,
    createdAt: DateTime.now(),
  );
}

AppNotification _approachingHarvest(CropModel crop, String displayName, int daysUntil, AppLanguage lang) {
  final isEn = lang == AppLanguage.english;
  return AppNotification(
    id: 'harvest_approaching_${crop.id}',
    title: isEn
        ? '$displayName harvest in $daysUntil days'
        : '$displayName e tla robwa mo malatsing a $daysUntil',
    body: isEn
        ? '${crop.fieldName} is approaching harvest time. Start planning ahead.'
        : '${crop.fieldName} e atamela nako ya go roba.',
    type: NotificationType.harvestReminder,
    priority: NotificationPriority.low,
    createdAt: DateTime.now(),
  );
}

AppNotification _criticalCondition(InventoryModel item, String displayName, AppLanguage lang) {
  final isEn = lang == AppLanguage.english;
  return AppNotification(
    id: 'inventory_critical_${item.id}',
    title: isEn
        ? '$displayName in critical condition'
        : '$displayName e mo maemong a maswe',
    body: isEn
        ? '${AgriKit.formatQuantity(item.quantity)} ${item.unit} at ${item.storageLocation} needs immediate attention.'
        : '${AgriKit.formatQuantity(item.quantity)} ${item.unit} kwa ${item.storageLocation} e tlhoka tlhokomelo ka bonako.',
    type: NotificationType.lowStock,
    priority: NotificationPriority.high,
    createdAt: item.updatedAt,
  );
}

AppNotification _needsAttention(InventoryModel item, String displayName, AppLanguage lang) {
  final isEn = lang == AppLanguage.english;
  return AppNotification(
    id: 'inventory_attention_${item.id}',
    title: isEn
        ? '$displayName needs attention'
        : '$displayName e tlhoka tlhokomelo',
    body: isEn
        ? '${AgriKit.formatQuantity(item.quantity)} ${item.unit} at ${item.storageLocation} condition is declining.'
        : '${AgriKit.formatQuantity(item.quantity)} ${item.unit} kwa ${item.storageLocation} maemo a a fokotsa.',
    type: NotificationType.lowStock,
    priority: NotificationPriority.medium,
    createdAt: item.updatedAt,
  );
}
