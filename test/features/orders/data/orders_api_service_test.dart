import 'package:agricola/features/orders/data/orders_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

void main() {
  late MockDio mockDio;
  late OrdersApiService apiService;

  final sampleItemData = {
    'listingId': 'listing-1',
    'title': 'Fresh Maize',
    'price': 25.50,
    'quantity': 10,
  };

  final sampleOrderData = {
    'id': '1',
    'userId': 'user-uid-123',
    'sellerId': 'seller-uid-456',
    'status': 'pending',
    'totalAmount': 255.0,
    'items': [sampleItemData],
    'createdAt': '2026-01-15T10:00:00.000',
    'updatedAt': '2026-01-15T12:00:00.000',
  };

  setUp(() {
    mockDio = MockDio();
    apiService = OrdersApiService(mockDio);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  // ---------------------------------------------------------------------------
  // getUserOrders
  // ---------------------------------------------------------------------------

  group('getUserOrders', () {
    test('returns list of orders from API response', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': [sampleOrderData]});
      when(() => mockDio.get('/api/v1/orders', queryParameters: null))
          .thenAnswer((_) async => response);

      final result = await apiService.getUserOrders();

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.status, 'pending');
    });

    test('returns empty list when API returns no items', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': []});
      when(() => mockDio.get('/api/v1/orders', queryParameters: null))
          .thenAnswer((_) async => response);

      final result = await apiService.getUserOrders();

      expect(result, isEmpty);
    });

    test('passes role query parameter when provided', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': []});
      when(
        () => mockDio.get(
          '/api/v1/orders',
          queryParameters: {'role': 'seller'},
        ),
      ).thenAnswer((_) async => response);

      await apiService.getUserOrders(role: 'seller');

      verify(
        () => mockDio.get(
          '/api/v1/orders',
          queryParameters: {'role': 'seller'},
        ),
      ).called(1);
    });

    test('omits query parameters when role is null', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': []});
      when(() => mockDio.get('/api/v1/orders', queryParameters: null))
          .thenAnswer((_) async => response);

      await apiService.getUserOrders();

      verify(
        () => mockDio.get('/api/v1/orders', queryParameters: null),
      ).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // getOrder
  // ---------------------------------------------------------------------------

  group('getOrder', () {
    test('returns single order from API response', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': sampleOrderData});
      when(() => mockDio.get('/api/v1/orders/1'))
          .thenAnswer((_) async => response);

      final result = await apiService.getOrder('1');

      expect(result.id, '1');
      expect(result.status, 'pending');
    });

    test('calls correct endpoint with id', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': sampleOrderData});
      when(() => mockDio.get('/api/v1/orders/42'))
          .thenAnswer((_) async => response);

      await apiService.getOrder('42');

      verify(() => mockDio.get('/api/v1/orders/42')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // updateOrderStatus
  // ---------------------------------------------------------------------------

  group('updateOrderStatus', () {
    test('sends PUT to correct endpoint with status body', () async {
      final confirmedOrder = {...sampleOrderData, 'status': 'confirmed'};
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': confirmedOrder});
      when(
        () => mockDio.put(
          '/api/v1/orders/1/status',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => response);

      final result = await apiService.updateOrderStatus('1', 'confirmed');

      expect(result.status, 'confirmed');
      verify(
        () => mockDio.put(
          '/api/v1/orders/1/status',
          data: {'status': 'confirmed'},
        ),
      ).called(1);
    });

    test('returns updated OrderModel', () async {
      final shippedOrder = {...sampleOrderData, 'status': 'shipped'};
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': shippedOrder});
      when(
        () => mockDio.put(
          '/api/v1/orders/1/status',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => response);

      final result = await apiService.updateOrderStatus('1', 'shipped');

      expect(result.id, '1');
      expect(result.status, 'shipped');
    });
  });

  // ---------------------------------------------------------------------------
  // cancelOrder
  // ---------------------------------------------------------------------------

  group('cancelOrder', () {
    test('sends DELETE to correct endpoint', () async {
      when(() => mockDio.delete('/api/v1/orders/1'))
          .thenAnswer((_) async => MockResponse());

      await apiService.cancelOrder('1');

      verify(() => mockDio.delete('/api/v1/orders/1')).called(1);
    });

    test('uses correct id in endpoint', () async {
      when(() => mockDio.delete('/api/v1/orders/99'))
          .thenAnswer((_) async => MockResponse());

      await apiService.cancelOrder('99');

      verify(() => mockDio.delete('/api/v1/orders/99')).called(1);
    });
  });
}
