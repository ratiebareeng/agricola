import 'dart:io';

import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile/data/datasources/firebase_storage_service.dart';
import 'package:agricola/features/profile/data/datasources/profile_api_service.dart';
import 'package:agricola/features/profile/data/datasources/profile_cache_service.dart';
import 'package:agricola/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:agricola/features/profile/domain/failures/profile_failure.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileApiService mockApiService;
  late MockProfileCacheService mockCacheService;
  late MockFirebaseStorageService mockStorageService;

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeFarmerProfileModel());
    registerFallbackValue(FakeMerchantProfileModel());
  });

  setUp(() {
    mockApiService = MockProfileApiService();
    mockCacheService = MockProfileCacheService();
    mockStorageService = MockFirebaseStorageService();

    repository = ProfileRepositoryImpl(
      apiService: mockApiService,
      cacheService: mockCacheService,
      storageService: mockStorageService,
    );
  });

  group('ProfileRepositoryImpl', () {
    final testDate = DateTime(2026, 1, 21, 10, 30);

    final farmerProfile = FarmerProfileModel(
      id: 'farmer-id-123',
      userId: 'user-123',
      village: 'Pandamatenga',
      customVillage: null,
      primaryCrops: ['Maize', 'Sorghum'],
      farmSize: '5-10 hectares',
      photoUrl: null,
      createdAt: testDate,
      updatedAt: testDate,
    );

    final merchantProfile = MerchantProfileModel(
      id: 'merchant-id-456',
      userId: 'user-456',
      businessName: 'Agri Shop',
      merchantType: MerchantType.agriShop,
      location: 'Kasane',
      customLocation: null,
      productsOffered: ['Seeds', 'Fertilizer'],
      photoUrl: null,
      createdAt: testDate,
      updatedAt: testDate,
    );

    group('createFarmerProfile', () {
      test('should create farmer profile and cache it', () async {
        when(
          () => mockApiService.createFarmerProfile(any()),
        ).thenAnswer((_) async => farmerProfile.toJson());
        when(
          () => mockCacheService.cacheFarmerProfile(any()),
        ).thenAnswer((_) async => {});

        final result = await repository.createFarmerProfile(
          profile: farmerProfile,
        );

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (profile) {
          expect(profile.id, farmerProfile.id);
          expect(profile.userId, farmerProfile.userId);
          expect(profile.village, farmerProfile.village);
        });

        verify(() => mockApiService.createFarmerProfile(any())).called(1);
        verify(() => mockCacheService.cacheFarmerProfile(any())).called(1);
      });

      test('should return failure on network error', () async {
        when(() => mockApiService.createFarmerProfile(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/profiles/farmer'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final result = await repository.createFarmerProfile(
          profile: farmerProfile,
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure.type, ProfileFailureType.networkError);
        }, (r) => fail('Should fail'));

        verifyNever(() => mockCacheService.cacheFarmerProfile(any()));
      });
    });

    group('createMerchantProfile', () {
      test('should create merchant profile and cache it', () async {
        when(
          () => mockApiService.createMerchantProfile(any()),
        ).thenAnswer((_) async => merchantProfile.toJson());
        when(
          () => mockCacheService.cacheMerchantProfile(any()),
        ).thenAnswer((_) async => {});

        final result = await repository.createMerchantProfile(
          profile: merchantProfile,
        );

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (profile) {
          expect(profile.id, merchantProfile.id);
          expect(profile.userId, merchantProfile.userId);
          expect(profile.businessName, merchantProfile.businessName);
        });

        verify(() => mockApiService.createMerchantProfile(any())).called(1);
        verify(() => mockCacheService.cacheMerchantProfile(any())).called(1);
      });
    });

    group('getProfile', () {
      test('should return cached profile if available', () async {
        when(
          () => mockCacheService.getCachedProfile(),
        ).thenReturn(FarmerProfileResponse(farmerProfile));

        final result = await repository.getProfile(userId: 'user-123');

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (profileResponse) {
          expect(profileResponse.userId, 'user-123');
          expect(profileResponse, isA<FarmerProfileResponse>());
        });

        verifyNever(() => mockApiService.getFarmerProfile(any()));
        verifyNever(() => mockApiService.getMerchantProfile(any()));
      });

      test('should fetch farmer profile from API if cache is empty', () async {
        when(() => mockCacheService.getCachedProfile()).thenReturn(null);
        when(
          () => mockApiService.getFarmerProfile(any()),
        ).thenAnswer((_) async => farmerProfile.toJson());
        when(
          () => mockCacheService.cacheFarmerProfile(any()),
        ).thenAnswer((_) async => {});

        final result = await repository.getProfile(userId: 'user-123');

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (profileResponse) {
          expect(profileResponse, isA<FarmerProfileResponse>());
          expect(profileResponse.userId, 'user-123');
        });

        verify(() => mockApiService.getFarmerProfile('user-123')).called(1);
        verify(() => mockCacheService.cacheFarmerProfile(any())).called(1);
      });

      test(
        'should fetch merchant profile if farmer profile returns 404',
        () async {
          when(() => mockCacheService.getCachedProfile()).thenReturn(null);
          when(() => mockApiService.getFarmerProfile(any())).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/api/profiles/farmer'),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: '/api/profiles/farmer'),
                statusCode: 404,
              ),
            ),
          );
          when(
            () => mockApiService.getMerchantProfile(any()),
          ).thenAnswer((_) async => merchantProfile.toJson());
          when(
            () => mockCacheService.cacheMerchantProfile(any()),
          ).thenAnswer((_) async => {});

          final result = await repository.getProfile(userId: 'user-456');

          expect(result.isRight(), true);
          result.fold((l) => fail('Should not fail'), (profileResponse) {
            expect(profileResponse, isA<MerchantProfileResponse>());
            expect(profileResponse.userId, 'user-456');
          });

          verify(() => mockApiService.getFarmerProfile('user-456')).called(1);
          verify(() => mockApiService.getMerchantProfile('user-456')).called(1);
          verify(() => mockCacheService.cacheMerchantProfile(any())).called(1);
        },
      );

      test('should return failure if profile not found', () async {
        when(() => mockCacheService.getCachedProfile()).thenReturn(null);
        when(() => mockApiService.getFarmerProfile(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/profiles/farmer'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/api/profiles/farmer'),
              statusCode: 404,
            ),
          ),
        );
        when(() => mockApiService.getMerchantProfile(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/profiles/merchant'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/api/profiles/merchant'),
              statusCode: 404,
            ),
          ),
        );

        final result = await repository.getProfile(userId: 'user-999');

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure.type, ProfileFailureType.notFound);
        }, (r) => fail('Should fail'));
      });
    });

    group('updateFarmerProfile', () {
      test('should update farmer profile and cache it', () async {
        final updatedProfile = farmerProfile.copyWith(
          village: 'Kasane',
          primaryCrops: ['Maize', 'Beans'],
        );

        when(
          () => mockApiService.updateFarmerProfile(any(), any()),
        ).thenAnswer((_) async => updatedProfile.toJson());
        when(
          () => mockCacheService.cacheFarmerProfile(any()),
        ).thenAnswer((_) async => {});

        final result = await repository.updateFarmerProfile(
          profile: updatedProfile,
        );

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (profile) {
          expect(profile.village, 'Kasane');
          expect(profile.primaryCrops, ['Maize', 'Beans']);
        });

        verify(
          () => mockApiService.updateFarmerProfile(any(), any()),
        ).called(1);
        verify(() => mockCacheService.cacheFarmerProfile(any())).called(1);
      });

      test('should return failure on server error', () async {
        when(() => mockApiService.updateFarmerProfile(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/profiles/farmer'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/api/profiles/farmer'),
              statusCode: 500,
            ),
          ),
        );

        final result = await repository.updateFarmerProfile(
          profile: farmerProfile,
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure.type, ProfileFailureType.serverError);
        }, (r) => fail('Should fail'));
      });
    });

    group('updateMerchantProfile', () {
      test('should update merchant profile and cache it', () async {
        final updatedProfile = merchantProfile.copyWith(
          businessName: 'Updated Agri Shop',
        );

        when(
          () => mockApiService.updateMerchantProfile(any(), any()),
        ).thenAnswer((_) async => updatedProfile.toJson());
        when(
          () => mockCacheService.cacheMerchantProfile(any()),
        ).thenAnswer((_) async => {});

        final result = await repository.updateMerchantProfile(
          profile: updatedProfile,
        );

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (profile) {
          expect(profile.businessName, 'Updated Agri Shop');
        });

        verify(
          () => mockApiService.updateMerchantProfile(any(), any()),
        ).called(1);
        verify(() => mockCacheService.cacheMerchantProfile(any())).called(1);
      });
    });

    group('deleteProfile', () {
      test('should delete profile and clear cache', () async {
        when(
          () => mockApiService.deleteProfile(any()),
        ).thenAnswer((_) async {});
        when(() => mockCacheService.clearCache()).thenAnswer((_) async {});

        final result = await repository.deleteProfile(profileId: 'profile-123');

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (u) => expect(u, unit));

        verify(() => mockApiService.deleteProfile('profile-123')).called(1);
        verify(() => mockCacheService.clearCache()).called(1);
      });

      test('should return failure on unauthorized error', () async {
        when(() => mockApiService.deleteProfile(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/profiles'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/api/profiles'),
              statusCode: 401,
            ),
          ),
        );

        final result = await repository.deleteProfile(profileId: 'profile-123');

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure.type, ProfileFailureType.unauthorized);
        }, (r) => fail('Should fail'));

        verifyNever(() => mockCacheService.clearCache());
      });
    });

    group('uploadProfilePhoto', () {
      test('should upload photo and return URL', () async {
        final file = FakeFile();
        const photoUrl =
            'https://storage.googleapis.com/profiles/user-123/avatar.jpg';

        when(
          () => mockStorageService.uploadProfilePhoto(any(), any()),
        ).thenAnswer((_) async => photoUrl);

        final result = await repository.uploadProfilePhoto(
          photoFile: file,
          userId: 'user-123',
        );

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not fail'),
          (url) => expect(url, photoUrl),
        );

        verify(
          () => mockStorageService.uploadProfilePhoto(file, 'user-123'),
        ).called(1);
      });

      test('should return failure on Firebase error', () async {
        final file = FakeFile();

        when(
          () => mockStorageService.uploadProfilePhoto(any(), any()),
        ).thenThrow(
          FirebaseException(
            plugin: 'firebase_storage',
            code: 'unknown',
            message: 'Upload failed',
          ),
        );

        final result = await repository.uploadProfilePhoto(
          photoFile: file,
          userId: 'user-123',
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure.type, ProfileFailureType.serverError);
          expect(failure.message, contains('Failed to upload photo'));
        }, (r) => fail('Should fail'));
      });
    });

    group('deleteProfilePhoto', () {
      test('should delete photo from storage', () async {
        const photoUrl =
            'https://firebasestorage.googleapis.com/v0/b/bucket/o/profiles%2Fuser-123%2Favatar.jpg?token=abc';

        when(
          () => mockStorageService.deleteProfilePhoto(any()),
        ).thenAnswer((_) async {});

        final result = await repository.deleteProfilePhoto(photoUrl: photoUrl);

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (u) => expect(u, unit));

        verify(() => mockStorageService.deleteProfilePhoto(any())).called(1);
      });

      test('should not fail if photo does not exist', () async {
        const photoUrl =
            'https://firebasestorage.googleapis.com/v0/b/bucket/o/profiles%2Fuser-123%2Favatar.jpg?token=abc';

        when(() => mockStorageService.deleteProfilePhoto(any())).thenThrow(
          FirebaseException(
            plugin: 'firebase_storage',
            code: 'object-not-found',
          ),
        );

        final result = await repository.deleteProfilePhoto(photoUrl: photoUrl);

        expect(result.isRight(), true);
      });
    });

    group('clearCache', () {
      test('should clear cache successfully', () async {
        when(() => mockCacheService.clearCache()).thenAnswer((_) async {});

        final result = await repository.clearCache();

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (u) => expect(u, unit));

        verify(() => mockCacheService.clearCache()).called(1);
      });
    });

    group('refreshProfile', () {
      test('should bypass cache and fetch fresh farmer profile', () async {
        when(
          () => mockApiService.getFarmerProfile(any()),
        ).thenAnswer((_) async => farmerProfile.toJson());
        when(
          () => mockCacheService.cacheFarmerProfile(any()),
        ).thenAnswer((_) async => {});

        final result = await repository.refreshProfile(userId: 'user-123');

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not fail'), (profileResponse) {
          expect(profileResponse, isA<FarmerProfileResponse>());
          expect(profileResponse.userId, 'user-123');
        });

        verifyNever(() => mockCacheService.getCachedProfile());
        verify(() => mockApiService.getFarmerProfile('user-123')).called(1);
        verify(() => mockCacheService.cacheFarmerProfile(any())).called(1);
      });
    });
  });
}

class FakeFarmerProfileModel extends Fake implements FarmerProfileModel {}

class FakeFile extends Fake implements File {}

class FakeMerchantProfileModel extends Fake implements MerchantProfileModel {}

class MockFirebaseStorageService extends Mock
    implements FirebaseStorageService {}

class MockProfileApiService extends Mock implements ProfileApiService {}

class MockProfileCacheService extends Mock implements ProfileCacheService {}
