import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/purchases/data/purchases_api_service.dart';
import 'package:agricola/features/purchases/models/purchase_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final purchasesApiServiceProvider = Provider<PurchasesApiService>((ref) {
  return PurchasesApiService(ref.watch(httpClientProvider));
});

final purchasesNotifierProvider = StateNotifierProvider<PurchasesNotifier,
    AsyncValue<List<PurchaseModel>>>((ref) {
  return PurchasesNotifier(ref.watch(purchasesApiServiceProvider));
});

class PurchasesNotifier
    extends StateNotifier<AsyncValue<List<PurchaseModel>>> {
  final PurchasesApiService _service;

  PurchasesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    state = const AsyncValue.loading();
    try {
      final purchases = await _service.getPurchases();
      state = AsyncValue.data(purchases);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> addPurchase(PurchaseModel purchase) async {
    try {
      final created = await _service.createPurchase(purchase);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updatePurchase(String id, PurchaseModel purchase) async {
    try {
      final updated = await _service.updatePurchase(id, purchase);
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
      await _service.deletePurchase(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((p) => p.id != id).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
