import 'package:agricola/core/database/daos/orders_local_dao.dart';
import 'package:agricola/core/services/analytics_service.dart';
import 'package:agricola/features/orders/data/orders_api_service.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/orders/providers/orders_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersApiService extends Mock implements OrdersApiService {}

class MockOrdersLocalDao extends Mock implements OrdersLocalDao {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

OrderModel _makeOrder({String? id, String status = 'pending'}) {
  return OrderModel(
    id: id,
    userId: 'user-uid-123',
    sellerId: 'seller-uid-456',
    status: status,
    totalAmount: 255.0,
    items: [
      OrderItem(
        listingId: 'listing-1',
        title: 'Fresh Maize',
        price: 25.50,
        quantity: 10,
      ),
    ],
    createdAt: DateTime(2026, 1, 15, 10),
    updatedAt: DateTime(2026, 1, 15, 12),
  );
}

void main() {
  late MockOrdersApiService mockApi;
  late MockOrdersLocalDao mockDao;
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockApi = MockOrdersApiService();
    mockDao = MockOrdersLocalDao();
    mockAnalytics = MockAnalyticsService();

    // Default analytics stub — no-op
    when(
      () => mockAnalytics.logOrderStatusUpdated(status: any(named: 'status')),
    ).thenAnswer((_) async {});
  });

  /// Creates a notifier with controllable online/offline state.
  OrdersNotifier createNotifier({
    List<OrderModel> initialData = const [],
    bool isOnline = true,
    bool offlineEnabled = false,
  }) {
    when(() => mockApi.getUserOrders(role: any(named: 'role')))
        .thenAnswer((_) async => initialData);
    when(() => mockDao.cacheAll(any())).thenAnswer((_) async {});
    when(() => mockDao.getAll()).thenAnswer((_) async => initialData);

    return OrdersNotifier(
      service: mockApi,
      localDao: mockDao,
      isOnline: () => isOnline,
      offlineEnabled: () => offlineEnabled,
      analytics: mockAnalytics,
    );
  }

  /// Wait for the constructor's loadOrders() to settle.
  Future<void> waitForLoad() async {
    await Future<void>.delayed(Duration.zero);
  }

  // ---------------------------------------------------------------------------
  // loadOrders
  // ---------------------------------------------------------------------------

  group('loadOrders', () {
    test('sets data on success (online)', () async {
      final orders = [_makeOrder(id: '1'), _makeOrder(id: '2')];
      final notifier = createNotifier(initialData: orders);

      await waitForLoad();

      expect(notifier.state, isA<AsyncData<List<OrderModel>>>());
      expect(notifier.state.value!.length, 2);
    });

    test('caches to local DAO when online + offline enabled', () async {
      final orders = [_makeOrder(id: '1')];
      final notifier = createNotifier(
        initialData: orders,
        isOnline: true,
        offlineEnabled: true,
      );

      await waitForLoad();

      verify(() => mockDao.cacheAll(orders)).called(1);
    });

    test('returns cached data when offline + offline enabled', () async {
      final cached = [_makeOrder(id: 'cached-1')];
      when(() => mockDao.getAll()).thenAnswer((_) async => cached);

      final notifier = OrdersNotifier(
        service: mockApi,
        localDao: mockDao,
        isOnline: () => false,
        offlineEnabled: () => true,
        analytics: mockAnalytics,
      );

      await waitForLoad();

      expect(notifier.state, isA<AsyncData<List<OrderModel>>>());
      expect(notifier.state.value!.first.id, 'cached-1');
      verifyNever(() => mockApi.getUserOrders(role: any(named: 'role')));
    });

    test('falls back to cache when API fails + offline enabled + cache not empty',
        () async {
      final cached = [_makeOrder(id: 'cached-1')];
      when(() => mockApi.getUserOrders(role: any(named: 'role')))
          .thenThrow(Exception('Network error'));
      when(() => mockDao.getAll()).thenAnswer((_) async => cached);
      when(() => mockDao.cacheAll(any())).thenAnswer((_) async {});

      final notifier = OrdersNotifier(
        service: mockApi,
        localDao: mockDao,
        isOnline: () => true,
        offlineEnabled: () => true,
        analytics: mockAnalytics,
      );

      await waitForLoad();

      expect(notifier.state, isA<AsyncData<List<OrderModel>>>());
      expect(notifier.state.value!.first.id, 'cached-1');
    });

    test('sets error when API fails + offline disabled', () async {
      when(() => mockApi.getUserOrders(role: any(named: 'role')))
          .thenThrow(Exception('Network error'));

      final notifier = OrdersNotifier(
        service: mockApi,
        localDao: mockDao,
        isOnline: () => true,
        offlineEnabled: () => false,
        analytics: mockAnalytics,
      );

      await waitForLoad();

      expect(notifier.state, isA<AsyncError<List<OrderModel>>>());
    });

    test('sets error when API fails + offline enabled + cache empty', () async {
      when(() => mockApi.getUserOrders(role: any(named: 'role')))
          .thenThrow(Exception('Network error'));
      when(() => mockDao.getAll()).thenAnswer((_) async => []);
      when(() => mockDao.cacheAll(any())).thenAnswer((_) async {});

      final notifier = OrdersNotifier(
        service: mockApi,
        localDao: mockDao,
        isOnline: () => true,
        offlineEnabled: () => true,
        analytics: mockAnalytics,
      );

      await waitForLoad();

      expect(notifier.state, isA<AsyncError<List<OrderModel>>>());
    });

    test('passes role parameter to API service', () async {
      final notifier = createNotifier(initialData: []);
      await waitForLoad();

      when(() => mockApi.getUserOrders(role: 'buyer'))
          .thenAnswer((_) async => []);

      await notifier.loadOrders(role: 'buyer');

      verify(() => mockApi.getUserOrders(role: 'buyer')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // updateOrderStatus
  // ---------------------------------------------------------------------------

  group('updateOrderStatus', () {
    test('replaces matching order in state and returns null on success',
        () async {
      final original = _makeOrder(id: '1', status: 'pending');
      final notifier = createNotifier(initialData: [original]);
      await waitForLoad();

      final updated = original.copyWith(status: 'confirmed');
      when(() => mockApi.updateOrderStatus('1', 'confirmed'))
          .thenAnswer((_) async => updated);

      final result = await notifier.updateOrderStatus('1', 'confirmed');

      expect(result, isNull);
      expect(notifier.state.value!.first.status, 'confirmed');
      expect(notifier.state.value!.length, 1);
    });

    test('logs analytics event on success', () async {
      final order = _makeOrder(id: '1');
      final notifier = createNotifier(initialData: [order]);
      await waitForLoad();

      when(() => mockApi.updateOrderStatus('1', 'confirmed'))
          .thenAnswer((_) async => order.copyWith(status: 'confirmed'));

      await notifier.updateOrderStatus('1', 'confirmed');

      verify(
        () => mockAnalytics.logOrderStatusUpdated(status: 'confirmed'),
      ).called(1);
    });

    test('returns error key string on failure', () async {
      final order = _makeOrder(id: '1');
      final notifier = createNotifier(initialData: [order]);
      await waitForLoad();

      when(() => mockApi.updateOrderStatus('1', 'confirmed'))
          .thenThrow(Exception('Update failed'));

      final result = await notifier.updateOrderStatus('1', 'confirmed');

      expect(result, equals('error_unexpected'));
    });

    test('does not modify state on failure', () async {
      final order = _makeOrder(id: '1', status: 'pending');
      final notifier = createNotifier(initialData: [order]);
      await waitForLoad();

      when(() => mockApi.updateOrderStatus('1', 'confirmed'))
          .thenThrow(Exception('Update failed'));

      await notifier.updateOrderStatus('1', 'confirmed');

      expect(notifier.state.value!.first.status, 'pending');
    });
  });

  // ---------------------------------------------------------------------------
  // cancelOrder
  // ---------------------------------------------------------------------------

  group('cancelOrder', () {
    test('updates matching order status to cancelled and returns null',
        () async {
      final order = _makeOrder(id: '1', status: 'pending');
      final notifier = createNotifier(initialData: [order]);
      await waitForLoad();

      when(() => mockApi.cancelOrder('1')).thenAnswer((_) async {});

      final result = await notifier.cancelOrder('1');

      expect(result, isNull);
      expect(notifier.state.value!.first.status, 'cancelled');
      expect(notifier.state.value!.length, 1);
    });

    test('only updates the matching order when multiple exist', () async {
      final order1 = _makeOrder(id: '1', status: 'pending');
      final order2 = _makeOrder(id: '2', status: 'confirmed');
      final notifier = createNotifier(initialData: [order1, order2]);
      await waitForLoad();

      when(() => mockApi.cancelOrder('1')).thenAnswer((_) async {});

      await notifier.cancelOrder('1');

      expect(notifier.state.value!.first.status, 'cancelled');
      expect(notifier.state.value![1].status, 'confirmed');
    });

    test('returns error key string on failure', () async {
      final order = _makeOrder(id: '1');
      final notifier = createNotifier(initialData: [order]);
      await waitForLoad();

      when(() => mockApi.cancelOrder('1'))
          .thenThrow(Exception('Cancel failed'));

      final result = await notifier.cancelOrder('1');

      expect(result, equals('error_unexpected'));
    });

    test('does not modify state on failure', () async {
      final order = _makeOrder(id: '1', status: 'pending');
      final notifier = createNotifier(initialData: [order]);
      await waitForLoad();

      when(() => mockApi.cancelOrder('1'))
          .thenThrow(Exception('Cancel failed'));

      await notifier.cancelOrder('1');

      expect(notifier.state.value!.first.status, 'pending');
    });
  });
}
