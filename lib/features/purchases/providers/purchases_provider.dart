import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/services/analytics_service.dart';
import 'package:agricola/core/database/daos/purchases_local_dao.dart';
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/features/purchases/data/purchases_api_service.dart';
import 'package:agricola/features/purchases/data/purchases_offline_repository.dart';
import 'package:agricola/features/purchases/models/purchase_model.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final purchasesApiServiceProvider = Provider<PurchasesApiService>((ref) {
  return PurchasesApiService(ref.watch(httpClientProvider));
});

final purchasesLocalDaoProvider = Provider<PurchasesLocalDao>((ref) {
  return PurchasesLocalDao(ref.watch(databaseProvider));
});

final purchasesOfflineRepositoryProvider =
    Provider<PurchasesOfflineRepository>((ref) {
  return PurchasesOfflineRepository(
    apiService: ref.watch(purchasesApiServiceProvider),
    localDao: ref.watch(purchasesLocalDaoProvider),
    db: ref.watch(databaseProvider),
    isOnline: () => ref.read(isOnlineProvider),
    offlineEnabled: () => ref.read(offlineModeEnabledProvider),
  );
});

final purchasesNotifierProvider = StateNotifierProvider<PurchasesNotifier,
    AsyncValue<List<PurchaseModel>>>((ref) {
  // Re-fetch purchases when user changes
  ref.watch(currentUserProvider);
  return PurchasesNotifier(
    ref.watch(purchasesOfflineRepositoryProvider),
    ref.watch(analyticsServiceProvider),
  );
});

class PurchasesNotifier
    extends StateNotifier<AsyncValue<List<PurchaseModel>>> {
  final PurchasesOfflineRepository _repository;
  final AnalyticsService _analytics;

  PurchasesNotifier(this._repository, this._analytics) : super(const AsyncValue.loading()) {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    state = const AsyncValue.loading();
    try {
      final purchases = await _repository.getPurchases();
      state = AsyncValue.data(purchases);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> addPurchase(PurchaseModel purchase) async {
    try {
      final created = await _repository.createPurchase(purchase);
      state = AsyncValue.data([created, ...state.value ?? []]);
      _analytics.logPurchaseRecorded();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updatePurchase(String id, PurchaseModel purchase) async {
    try {
      final updated = await _repository.updatePurchase(id, purchase);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((p) => p.id == id ? updated : p).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deletePurchase(String id) async {
    try {
      await _repository.deletePurchase(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((p) => p.id != id).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
