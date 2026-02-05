import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/orders/data/orders_api_service.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the OrdersApiService with auto-wired Dio client
final ordersApiServiceProvider = Provider<OrdersApiService>((ref) {
  return OrdersApiService(ref.watch(httpClientProvider));
});

/// Provides the OrdersNotifier for managing order state
final ordersNotifierProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  return OrdersNotifier(ref.watch(ordersApiServiceProvider));
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrdersApiService _service;

  OrdersNotifier(this._service) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  /// Fetch orders from the backend (as seller by default for AgriShop)
  Future<void> loadOrders({String? role = 'seller'}) async {
    state = const AsyncValue.loading();
    try {
      final orders = await _service.getUserOrders(role: role);
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update order status. Returns null on success, error message on failure.
  Future<String?> updateOrderStatus(String id, String status) async {
    try {
      final updated = await _service.updateOrderStatus(id, status);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((o) => o.id == id ? updated : o).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Cancel an order. Returns null on success, error message on failure.
  Future<String?> cancelOrder(String id) async {
    try {
      await _service.cancelOrder(id);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((o) => o.id == id ? o.copyWith(status: 'cancelled') : o).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
