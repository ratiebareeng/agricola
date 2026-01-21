import 'package:agricola/features/profile/data/datasources/profile_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockDio mockDio;
  late ProfileApiService apiService;

  setUp(() {
    mockDio = MockDio();
    apiService = ProfileApiService(mockDio);
  });

  group('ProfileApiService', () {
    group('createFarmerProfile', () {
      test('should post farmer profile data and return response', () async {
        final profileData = {
          'userId': 'user-123',
          'village': 'Pandamatenga',
          'primaryCrops': ['Maize', 'Sorghum'],
          'farmSize': '5-10 hectares',
        };

        final responseData = {
          'id': 'profile-123',
          ...profileData,
          'createdAt': '2026-01-21T10:30:00.000Z',
          'updatedAt': '2026-01-21T10:30:00.000Z',
        };

        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn(responseData);
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => mockResponse);

        final result = await apiService.createFarmerProfile(profileData);

        expect(result, responseData);
        verify(
          () => mockDio.post(ProfileApiEndpoints.farmerPath, data: profileData),
        ).called(1);
      });

      test('should throw DioException on network error', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/profiles/farmer'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(
          () => apiService.createFarmerProfile({}),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('createMerchantProfile', () {
      test('should post merchant profile data and return response', () async {
        final profileData = {
          'userId': 'user-123',
          'businessName': 'Agri Shop',
          'merchantType': 'agriShop',
          'location': 'Pandamatenga',
        };

        final responseData = {
          'id': 'profile-456',
          ...profileData,
          'createdAt': '2026-01-21T10:30:00.000Z',
          'updatedAt': '2026-01-21T10:30:00.000Z',
        };

        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn(responseData);
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => mockResponse);

        final result = await apiService.createMerchantProfile(profileData);

        expect(result, responseData);
        verify(
          () =>
              mockDio.post(ProfileApiEndpoints.merchantPath, data: profileData),
        ).called(1);
      });
    });

    group('getFarmerProfile', () {
      test('should get farmer profile by userId', () async {
        const userId = 'user-123';
        final responseData = {
          'id': 'profile-123',
          'userId': userId,
          'village': 'Pandamatenga',
          'primaryCrops': ['Maize'],
          'farmSize': '5-10 hectares',
          'createdAt': '2026-01-21T10:30:00.000Z',
          'updatedAt': '2026-01-21T10:30:00.000Z',
        };

        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn(responseData);
        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

        final result = await apiService.getFarmerProfile(userId);

        expect(result, responseData);
        verify(
          () => mockDio.get(ProfileApiEndpoints.getFarmerProfile(userId)),
        ).called(1);
      });

      test('should throw DioException when profile not found', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/profiles/farmer/user-123',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(
                path: '/api/profiles/farmer/user-123',
              ),
              statusCode: 404,
            ),
          ),
        );

        expect(
          () => apiService.getFarmerProfile('user-123'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getMerchantProfile', () {
      test('should get merchant profile by userId', () async {
        const userId = 'user-456';
        final responseData = {
          'id': 'profile-456',
          'userId': userId,
          'businessName': 'Agri Shop',
          'merchantType': 'agriShop',
          'location': 'Pandamatenga',
          'createdAt': '2026-01-21T10:30:00.000Z',
          'updatedAt': '2026-01-21T10:30:00.000Z',
        };

        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn(responseData);
        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

        final result = await apiService.getMerchantProfile(userId);

        expect(result, responseData);
        verify(
          () => mockDio.get(ProfileApiEndpoints.getMerchantProfile(userId)),
        ).called(1);
      });
    });

    group('updateFarmerProfile', () {
      test('should update farmer profile and return updated data', () async {
        const profileId = 'profile-123';
        final updates = {
          'village': 'Kasane',
          'primaryCrops': ['Maize', 'Beans', 'Sorghum'],
        };

        final responseData = {
          'id': profileId,
          'userId': 'user-123',
          ...updates,
          'farmSize': '5-10 hectares',
          'updatedAt': '2026-01-21T12:00:00.000Z',
        };

        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn(responseData);
        when(
          () => mockDio.put(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => mockResponse);

        final result = await apiService.updateFarmerProfile(profileId, updates);

        expect(result, responseData);
        verify(
          () => mockDio.put(
            ProfileApiEndpoints.updateFarmerProfile(profileId),
            data: updates,
          ),
        ).called(1);
      });
    });

    group('updateMerchantProfile', () {
      test('should update merchant profile and return updated data', () async {
        const profileId = 'profile-456';
        final updates = {
          'businessName': 'Updated Agri Shop',
          'location': 'Kasane',
        };

        final responseData = {
          'id': profileId,
          'userId': 'user-456',
          ...updates,
          'merchantType': 'agriShop',
          'updatedAt': '2026-01-21T12:00:00.000Z',
        };

        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn(responseData);
        when(
          () => mockDio.put(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => mockResponse);

        final result = await apiService.updateMerchantProfile(
          profileId,
          updates,
        );

        expect(result, responseData);
        verify(
          () => mockDio.put(
            ProfileApiEndpoints.updateMerchantProfile(profileId),
            data: updates,
          ),
        ).called(1);
      });
    });

    group('deleteProfile', () {
      test('should delete profile by profileId', () async {
        const profileId = 'profile-123';

        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn(null);
        when(() => mockDio.delete(any())).thenAnswer((_) async => mockResponse);

        await apiService.deleteProfile(profileId);

        verify(
          () => mockDio.delete(ProfileApiEndpoints.deleteProfile(profileId)),
        ).called(1);
      });

      test('should throw DioException on delete error', () async {
        when(() => mockDio.delete(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/profiles/123'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/api/profiles/123'),
              statusCode: 500,
            ),
          ),
        );

        expect(
          () => apiService.deleteProfile('profile-123'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('ProfileApiEndpoints', () {
      test('should generate correct endpoint paths', () {
        expect(ProfileApiEndpoints.basePath, '/api/profiles');
        expect(ProfileApiEndpoints.farmerPath, '/api/profiles/farmer');
        expect(ProfileApiEndpoints.merchantPath, '/api/profiles/merchant');
        expect(
          ProfileApiEndpoints.getFarmerProfile('user-123'),
          '/api/profiles/farmer/user-123',
        );
        expect(
          ProfileApiEndpoints.getMerchantProfile('user-456'),
          '/api/profiles/merchant/user-456',
        );
        expect(
          ProfileApiEndpoints.updateFarmerProfile('profile-123'),
          '/api/profiles/farmer/profile-123',
        );
        expect(
          ProfileApiEndpoints.updateMerchantProfile('profile-456'),
          '/api/profiles/merchant/profile-456',
        );
        expect(
          ProfileApiEndpoints.deleteProfile('profile-789'),
          '/api/profiles/profile-789',
        );
      });
    });
  });
}

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}
