import 'package:agricola/features/inventory/data/inventory_api_service.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

void main() {
  late MockDio mockDio;
  late InventoryApiService apiService;

  final sampleData = {
    'id': '1',
    'cropType': 'maize',
    'quantity': 100.0,
    'unit': 'kg',
    'storageDate': '2026-01-15T00:00:00.000',
    'storageLocation': 'Warehouse A',
    'condition': 'good',
    'notes': null,
    'createdAt': '2026-01-15T10:00:00.000',
    'updatedAt': '2026-01-15T12:00:00.000',
  };

  setUp(() {
    mockDio = MockDio();
    apiService = InventoryApiService(mockDio);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('getUserInventory', () {
    test('returns list of items from API response', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': [sampleData],
      });
      when(() => mockDio.get('/api/v1/inventory'))
          .thenAnswer((_) async => response);

      final result = await apiService.getUserInventory();

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.cropType, 'maize');
    });

    test('returns empty list when API returns no items', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': []});
      when(() => mockDio.get('/api/v1/inventory'))
          .thenAnswer((_) async => response);

      final result = await apiService.getUserInventory();

      expect(result, isEmpty);
    });
  });

  group('createInventory', () {
    test('posts data and returns created item', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': sampleData});
      when(() => mockDio.post('/api/v1/inventory', data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final item = InventoryModel(
        cropType: 'maize',
        quantity: 100,
        unit: 'kg',
        storageDate: DateTime(2026),
        storageLocation: 'Warehouse A',
        condition: 'good',
      );

      final result = await apiService.createInventory(item);

      expect(result.id, '1');
      verify(() => mockDio.post('/api/v1/inventory', data: any(named: 'data')))
          .called(1);
    });
  });

  group('updateInventory', () {
    test('puts data to correct endpoint and returns updated item', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': sampleData});
      when(() => mockDio.put('/api/v1/inventory/1', data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final item = InventoryModel(
        id: '1',
        cropType: 'maize',
        quantity: 100,
        unit: 'kg',
        storageDate: DateTime(2026),
        storageLocation: 'Warehouse A',
        condition: 'good',
      );

      final result = await apiService.updateInventory('1', item);

      expect(result.id, '1');
      verify(() =>
              mockDio.put('/api/v1/inventory/1', data: any(named: 'data')))
          .called(1);
    });
  });

  group('deleteInventory', () {
    test('sends delete to correct endpoint', () async {
      when(() => mockDio.delete('/api/v1/inventory/1'))
          .thenAnswer((_) async => MockResponse());

      await apiService.deleteInventory('1');

      verify(() => mockDio.delete('/api/v1/inventory/1')).called(1);
    });
  });
}
