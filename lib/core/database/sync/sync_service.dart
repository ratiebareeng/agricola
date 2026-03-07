import 'dart:convert';

import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/models/harvest_model.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/crops/providers/harvest_providers.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/orders/providers/orders_provider.dart';
import 'package:agricola/features/purchases/models/purchase_model.dart';
import 'package:agricola/features/purchases/providers/purchases_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while a sync cycle is in progress. Used by the UI to show a sync indicator.
final isSyncingProvider = StateProvider<bool>((ref) => false);

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

/// Listens to connectivity changes and triggers sync when coming online.
/// Only active when offline mode is enabled.
final syncTriggerProvider = Provider<void>((ref) {
  final offlineEnabled = ref.watch(offlineModeEnabledProvider);
  if (!offlineEnabled) return;

  final connectivity = ref.watch(connectivityProvider);
  if (connectivity == ConnectivityStatus.online) {
    ref.read(syncServiceProvider).syncAll();
  }
});

class SyncService {
  final Ref _ref;
  bool _isSyncing = false;

  SyncService(this._ref);

  AppDatabase get _db => _ref.read(databaseProvider);

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _ref.read(isSyncingProvider.notifier).state = true;

    try {
      final items = await _db.getPendingSyncItems();
      if (items.isEmpty) return;

      for (final item in items) {
        final isOnline = _ref.read(isOnlineProvider);
        if (!isOnline) break;

        await _processSyncItem(item);
      }

      // Clean up completed items and refresh all providers
      await _db.clearCompletedSyncItems();
      refreshProviders();
    } finally {
      _isSyncing = false;
      _ref.read(isSyncingProvider.notifier).state = false;
    }
  }

  Future<void> _processSyncItem(SyncQueueData item) async {
    await _db.updateSyncItemStatus(item.id, 'in_progress');

    try {
      final payload = jsonDecode(item.payload) as Map<String, dynamic>;

      switch (item.entityType) {
        case 'crop':
          await _syncCrop(item, payload);
        case 'inventory':
          await _syncInventory(item, payload);
        case 'harvest':
          await _syncHarvest(item, payload);
        case 'purchase':
          await _syncPurchase(item, payload);
        default:
          await _db.updateSyncItemStatus(
            item.id,
            'failed',
            errorMessage: 'Unknown entity type: ${item.entityType}',
          );
          return;
      }

      await _db.updateSyncItemStatus(item.id, 'completed');
    } catch (e) {
      final statusCode = _extractStatusCode(e);

      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        // Client error -- don't retry
        await _db.updateSyncItemStatus(
          item.id,
          'failed',
          errorMessage: e.toString(),
        );
      } else {
        // Server/network error -- retry later
        await _db.incrementRetryCount(item.id);
        await _db.updateSyncItemStatus(
          item.id,
          'pending',
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> _syncCrop(
      SyncQueueData item, Map<String, dynamic> payload) async {
    final service = _ref.read(cropApiServiceProvider);

    switch (item.operation) {
      case 'create':
        final crop = CropModel.fromJson(payload);
        final created = await service.createCrop(crop);
        await _db.replaceLocalId(
          entityType: 'crop',
          localId: item.localId,
          serverId: created.id!,
        );
      case 'update':
        final crop = CropModel.fromJson(payload);
        await service.updateCrop(item.entityId!, crop);
      case 'delete':
        await service.deleteCrop(item.entityId!);
    }
  }

  Future<void> _syncInventory(
      SyncQueueData item, Map<String, dynamic> payload) async {
    final service = _ref.read(inventoryApiServiceProvider);

    switch (item.operation) {
      case 'create':
        final inventoryItem = InventoryModel.fromJson(payload);
        final created = await service.createInventory(inventoryItem);
        await _db.replaceLocalId(
          entityType: 'inventory',
          localId: item.localId,
          serverId: created.id!,
        );
      case 'update':
        final inventoryItem = InventoryModel.fromJson(payload);
        await service.updateInventory(item.entityId!, inventoryItem);
      case 'delete':
        await service.deleteInventory(item.entityId!);
    }
  }

  Future<void> _syncHarvest(
      SyncQueueData item, Map<String, dynamic> payload) async {
    final service = _ref.read(harvestApiServiceProvider);

    switch (item.operation) {
      case 'create':
        final harvest = HarvestModel.fromJson(payload);
        final created = await service.createHarvest(harvest);
        await _db.replaceLocalId(
          entityType: 'harvest',
          localId: item.localId,
          serverId: created.id!,
        );
      case 'delete':
        await service.deleteHarvest(item.entityId!);
    }
  }

  Future<void> _syncPurchase(
      SyncQueueData item, Map<String, dynamic> payload) async {
    final service = _ref.read(purchasesApiServiceProvider);

    switch (item.operation) {
      case 'create':
        final purchase = PurchaseModel.fromJson(payload);
        final created = await service.createPurchase(purchase);
        await _db.replaceLocalId(
          entityType: 'purchase',
          localId: item.localId,
          serverId: created.id!,
        );
      case 'update':
        final purchase = PurchaseModel.fromJson(payload);
        await service.updatePurchase(item.entityId!, purchase);
      case 'delete':
        await service.deletePurchase(item.entityId!);
    }
  }

  int? _extractStatusCode(Object error) {
    if (error is String && error.contains('status')) {
      final match = RegExp(r'status (\d{3})').firstMatch(error);
      if (match != null) return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Refresh providers after sync to reflect server state.
  void refreshProviders() {
    _ref.invalidate(cropNotifierProvider);
    _ref.invalidate(inventoryNotifierProvider);
    _ref.invalidate(purchasesNotifierProvider);
    _ref.invalidate(marketplaceNotifierProvider);
    _ref.invalidate(ordersNotifierProvider);
  }
}
