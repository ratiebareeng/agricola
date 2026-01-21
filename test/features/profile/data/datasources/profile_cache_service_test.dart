import 'dart:convert';

import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile/data/datasources/profile_cache_service.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late ProfileCacheService cacheService;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    cacheService = ProfileCacheService(mockPrefs);
  });

  group('ProfileCacheService', () {
    final testDate = DateTime(2026, 1, 21, 10, 30);
    final farmerProfile = FarmerProfileModel(
      id: 'profile-123',
      userId: 'user-123',
      village: 'Pandamatenga',
      primaryCrops: ['Maize', 'Sorghum'],
      farmSize: '5-10 hectares',
      createdAt: testDate,
      updatedAt: testDate,
    );

    final merchantProfile = MerchantProfileModel(
      id: 'profile-456',
      userId: 'user-456',
      businessName: 'Agri Shop',
      merchantType: MerchantType.agriShop,
      location: 'Pandamatenga',
      productsOffered: ['Fertilizers', 'Seeds'],
      createdAt: testDate,
      updatedAt: testDate,
    );

    group('cacheFarmerProfile', () {
      test('should cache farmer profile successfully', () async {
        when(
          () => mockPrefs.setString(any(), any()),
        ).thenAnswer((_) async => true);

        await cacheService.cacheFarmerProfile(farmerProfile);

        verify(
          () => mockPrefs.setString(
            'cached_farmer_profile',
            jsonEncode(farmerProfile.toJson()),
          ),
        ).called(1);
        verify(
          () => mockPrefs.setString('cached_user_type', UserType.farmer.name),
        ).called(1);
        verify(
          () => mockPrefs.setString('profile_cache_timestamp', any()),
        ).called(1);
      });
    });

    group('cacheMerchantProfile', () {
      test('should cache merchant profile successfully', () async {
        when(
          () => mockPrefs.setString(any(), any()),
        ).thenAnswer((_) async => true);

        await cacheService.cacheMerchantProfile(merchantProfile);

        verify(
          () => mockPrefs.setString(
            'cached_merchant_profile',
            jsonEncode(merchantProfile.toJson()),
          ),
        ).called(1);
        verify(
          () => mockPrefs.setString('cached_user_type', UserType.merchant.name),
        ).called(1);
        verify(
          () => mockPrefs.setString('profile_cache_timestamp', any()),
        ).called(1);
      });
    });

    group('getCachedProfile', () {
      test('should return cached farmer profile when valid', () {
        final cacheTime = DateTime.now().subtract(const Duration(hours: 1));
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(cacheTime.toIso8601String());
        when(
          () => mockPrefs.getString('cached_user_type'),
        ).thenReturn(UserType.farmer.name);
        when(
          () => mockPrefs.getString('cached_farmer_profile'),
        ).thenReturn(jsonEncode(farmerProfile.toJson()));

        final result = cacheService.getCachedProfile();

        expect(result, isA<FarmerProfileResponse>());
        expect((result as FarmerProfileResponse).profile.id, 'profile-123');
        expect(result.profile.village, 'Pandamatenga');
      });

      test('should return cached merchant profile when valid', () {
        final cacheTime = DateTime.now().subtract(const Duration(hours: 1));
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(cacheTime.toIso8601String());
        when(
          () => mockPrefs.getString('cached_user_type'),
        ).thenReturn(UserType.merchant.name);
        when(
          () => mockPrefs.getString('cached_merchant_profile'),
        ).thenReturn(jsonEncode(merchantProfile.toJson()));

        final result = cacheService.getCachedProfile();

        expect(result, isA<MerchantProfileResponse>());
        expect((result as MerchantProfileResponse).profile.id, 'profile-456');
        expect(result.profile.businessName, 'Agri Shop');
      });

      test('should return null when cache is expired', () {
        final expiredTime = DateTime.now().subtract(const Duration(hours: 25));
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(expiredTime.toIso8601String());

        final result = cacheService.getCachedProfile();

        expect(result, isNull);
      });

      test('should return null when no cache exists', () {
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(null);

        final result = cacheService.getCachedProfile();

        expect(result, isNull);
      });

      test('should return null when user type is not cached', () {
        final cacheTime = DateTime.now().subtract(const Duration(hours: 1));
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(cacheTime.toIso8601String());
        when(() => mockPrefs.getString('cached_user_type')).thenReturn(null);

        final result = cacheService.getCachedProfile();

        expect(result, isNull);
      });

      test('should return null when cached profile data is invalid JSON', () {
        final cacheTime = DateTime.now().subtract(const Duration(hours: 1));
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(cacheTime.toIso8601String());
        when(
          () => mockPrefs.getString('cached_user_type'),
        ).thenReturn(UserType.farmer.name);
        when(
          () => mockPrefs.getString('cached_farmer_profile'),
        ).thenReturn('invalid json');

        final result = cacheService.getCachedProfile();

        expect(result, isNull);
      });

      test('should return null when profile data is null', () {
        final cacheTime = DateTime.now().subtract(const Duration(hours: 1));
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(cacheTime.toIso8601String());
        when(
          () => mockPrefs.getString('cached_user_type'),
        ).thenReturn(UserType.farmer.name);
        when(
          () => mockPrefs.getString('cached_farmer_profile'),
        ).thenReturn(null);

        final result = cacheService.getCachedProfile();

        expect(result, isNull);
      });
    });

    group('clearCache', () {
      test('should clear all cached profile data', () async {
        when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

        await cacheService.clearCache();

        verify(() => mockPrefs.remove('cached_farmer_profile')).called(1);
        verify(() => mockPrefs.remove('cached_merchant_profile')).called(1);
        verify(() => mockPrefs.remove('profile_cache_timestamp')).called(1);
        verify(() => mockPrefs.remove('cached_user_type')).called(1);
      });
    });

    group('cache TTL validation', () {
      test('should validate cache within 24 hours as valid', () {
        final recentTime = DateTime.now().subtract(const Duration(hours: 23));
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(recentTime.toIso8601String());
        when(
          () => mockPrefs.getString('cached_user_type'),
        ).thenReturn(UserType.farmer.name);
        when(
          () => mockPrefs.getString('cached_farmer_profile'),
        ).thenReturn(jsonEncode(farmerProfile.toJson()));

        final result = cacheService.getCachedProfile();

        expect(result, isNotNull);
      });

      test('should invalidate cache older than 24 hours', () {
        final oldTime = DateTime.now().subtract(
          const Duration(hours: 24, minutes: 1),
        );
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn(oldTime.toIso8601String());

        final result = cacheService.getCachedProfile();

        expect(result, isNull);
      });

      test('should handle invalid timestamp format', () {
        when(
          () => mockPrefs.getString('profile_cache_timestamp'),
        ).thenReturn('invalid-date');

        final result = cacheService.getCachedProfile();

        expect(result, isNull);
      });
    });
  });
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
