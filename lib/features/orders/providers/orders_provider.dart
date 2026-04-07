import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/services/analytics_service.dart';
import 'package:agricola/core/database/daos/orders_local_dao.dart';
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/features/orders/data/orders_api_service.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the OrdersApiService with auto-wired Dio client
final ordersApiServiceProvider = Provider<OrdersApiService>((ref) {
  return OrdersApiService(ref.watch(httpClientProvider));
});

final ordersLocalDaoProvider = Provider<OrdersLocalDao>((ref) {
  return OrdersLocalDao(ref.watch(databaseProvider));
});

/// Provides the OrdersNotifier for managing order state
final ordersNotifierProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  // Re-fetch orders when user changes
  ref.watch(currentUserProvider);
  
  return OrdersNotifier(
    service: ref.watch(ordersApiServiceProvider),
    localDao: ref.watch(ordersLocalDaoProvider),
    isOnline: () => ref.read(isOnlineProvider),
    offlineEnabled: () => ref.read(offlineModeEnabledProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrdersApiService _service;
  final OrdersLocalDao _localDao;
  final bool Function() _isOnline;
  final bool Function() _offlineEnabled;
  final AnalyticsService _analytics;

  OrdersNotifier({
    required OrdersApiService service,
    required OrdersLocalDao localDao,
    required bool Function() isOnline,
    required bool Function() offlineEnabled,
    required AnalyticsService analytics,
  })  : _service = service,
        _localDao = localDao,
        _isOnline = isOnline,
        _offlineEnabled = offlineEnabled,
        _analytics = analytics,
        super(const AsyncValue.loading()) {
    loadOrders();
  }

  /// Fetch orders from backend (or local cache when offline). Read-only offline.
  Future<void> loadOrders({String? role = 'seller'}) async {
    state = const AsyncValue.loading();
    try {
      if (_offlineEnabled() && !_isOnline()) {
        final cached = await _localDao.getAll();
        state = AsyncValue.data(cached);
        return;
      }

      final orders = await _service.getUserOrders(role: role);
      if (_offlineEnabled()) await _localDao.cacheAll(orders);
      state = AsyncValue.data(orders);
    } catch (e, st) {
      if (_offlineEnabled()) {
        final cached = await _localDao.getAll();
        if (cached.isNotEmpty) {
          state = AsyncValue.data(cached);
          return;
        }
      }
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
      _analytics.logOrderStatusUpdated(status: status);
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
