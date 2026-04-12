import 'package:agricola/features/marketplace/data/marketplace_api_service.dart';
import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

void main() {
  late MockDio mockDio;
  late MarketplaceApiService apiService;

  final sampleData = {
    'id': '1',
    'title': 'Fresh Maize',
    'description': 'Organic maize',
    'type': 'produce',
    'category': 'cereals',
    'price': 25.0,
    'unit': 'kg',
    'sellerName': 'John',
    'sellerId': 'user-1',
    'location': 'Gaborone',
    'status': 'harvested',
    'harvestDate': null,
    'quantity': '100',
    'imagePath': null,
    'sellerPhone': null,
    'sellerEmail': null,
    'additionalImages': null,
    'inventoryId': null,
    'createdAt': '2026-03-15T10:00:00.000',
  };

  setUp(() {
    mockDio = MockDio();
    apiService = MarketplaceApiService(mockDio);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('getListings', () {
    test('returns list from API response', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': [sampleData],
      });
      when(() => mockDio.get(
            '/api/v1/marketplace',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      final result = await apiService.getListings();

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'Fresh Maize');
    });

    test('returns empty list when no items', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': []});
      when(() => mockDio.get(
            '/api/v1/marketplace',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      final result = await apiService.getListings();

      expect(result, isEmpty);
    });

    test('passes filter query parameters', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': []});
      when(() => mockDio.get(
            '/api/v1/marketplace',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      const filter = MarketplaceFilter(
        searchQuery: 'maize',
        category: 'cereals',
      );
      await apiService.getListings(filter: filter);

      verify(() => mockDio.get(
            '/api/v1/marketplace',
            queryParameters: {'search': 'maize', 'category': 'cereals'},
          )).called(1);
    });
  });

  group('getListing', () {
    test('returns single listing', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': sampleData});
      when(() => mockDio.get('/api/v1/marketplace/1'))
          .thenAnswer((_) async => response);

      final result = await apiService.getListing('1');

      expect(result.id, '1');
      expect(result.title, 'Fresh Maize');
    });
  });

  group('createListing', () {
    test('posts data and returns created listing', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': sampleData});
      when(() =>
              mockDio.post('/api/v1/marketplace', data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final listing = MarketplaceListing.fromJson(sampleData);
      final result = await apiService.createListing(listing);

      expect(result.id, '1');
      verify(() =>
              mockDio.post('/api/v1/marketplace', data: any(named: 'data')))
          .called(1);
    });
  });

  group('updateListing', () {
    test('puts data to correct endpoint', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'data': sampleData});
      when(() =>
              mockDio.put('/api/v1/marketplace/1', data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final listing = MarketplaceListing.fromJson(sampleData);
      final result = await apiService.updateListing('1', listing);

      expect(result.id, '1');
      verify(() =>
              mockDio.put('/api/v1/marketplace/1', data: any(named: 'data')))
          .called(1);
    });
  });

  group('deleteListing', () {
    test('sends delete to correct endpoint', () async {
      when(() => mockDio.delete('/api/v1/marketplace/1'))
          .thenAnswer((_) async => MockResponse());

      await apiService.deleteListing('1');

      verify(() => mockDio.delete('/api/v1/marketplace/1')).called(1);
    });
  });
}
