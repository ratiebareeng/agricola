import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileResponse', () {
    final testDate = DateTime(2026, 1, 21, 10, 30);

    final farmerProfile = FarmerProfileModel(
      id: 'farmer-id-123',
      userId: 'user-123',
      village: 'Pandamatenga',
      customVillage: null,
      primaryCrops: ['Maize', 'Sorghum'],
      farmSize: '5-10 hectares',
      photoUrl: 'https://example.com/farmer.jpg',
      createdAt: testDate,
      updatedAt: testDate,
    );

    final merchantProfile = MerchantProfileModel(
      id: 'merchant-id-456',
      userId: 'user-456',
      merchantType: MerchantType.agriShop,
      businessName: 'Agri Supplies',
      location: 'Kasane',
      customLocation: null,
      productsOffered: ['Seeds', 'Tools'],
      photoUrl: 'https://example.com/shop.jpg',
      createdAt: testDate,
      updatedAt: testDate,
    );

    group('FarmerProfileResponse', () {
      test('should wrap FarmerProfileModel', () {
        final response = FarmerProfileResponse(farmerProfile);

        expect(response.profile, farmerProfile);
      });

      test('should implement Equatable correctly', () {
        final response1 = FarmerProfileResponse(farmerProfile);
        final response2 = FarmerProfileResponse(farmerProfile);

        expect(response1, response2);
        expect(response1.hashCode, response2.hashCode);
      });
    });

    group('MerchantProfileResponse', () {
      test('should wrap MerchantProfileModel', () {
        final response = MerchantProfileResponse(merchantProfile);

        expect(response.profile, merchantProfile);
      });

      test('should implement Equatable correctly', () {
        final response1 = MerchantProfileResponse(merchantProfile);
        final response2 = MerchantProfileResponse(merchantProfile);

        expect(response1, response2);
        expect(response1.hashCode, response2.hashCode);
      });
    });

    group('ProfileResponseX extensions', () {
      test('userId should return correct userId for FarmerProfileResponse', () {
        final response = FarmerProfileResponse(farmerProfile);

        expect(response.userId, 'user-123');
      });

      test(
        'userId should return correct userId for MerchantProfileResponse',
        () {
          final response = MerchantProfileResponse(merchantProfile);

          expect(response.userId, 'user-456');
        },
      );

      test('id should return correct id for FarmerProfileResponse', () {
        final response = FarmerProfileResponse(farmerProfile);

        expect(response.id, 'farmer-id-123');
      });

      test('id should return correct id for MerchantProfileResponse', () {
        final response = MerchantProfileResponse(merchantProfile);

        expect(response.id, 'merchant-id-456');
      });

      test(
        'photoUrl should return correct photoUrl for FarmerProfileResponse',
        () {
          final response = FarmerProfileResponse(farmerProfile);

          expect(response.photoUrl, 'https://example.com/farmer.jpg');
        },
      );

      test(
        'photoUrl should return correct photoUrl for MerchantProfileResponse',
        () {
          final response = MerchantProfileResponse(merchantProfile);

          expect(response.photoUrl, 'https://example.com/shop.jpg');
        },
      );

      test('photoUrl should return null when profile has no photo', () {
        final profileWithoutPhoto = FarmerProfileModel(
          id: 'farmer-id',
          userId: 'user-123',
          village: 'Pandamatenga',
          primaryCrops: ['Maize'],
          farmSize: '1-5 hectares',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final response = FarmerProfileResponse(profileWithoutPhoto);

        expect(response.photoUrl, isNull);
      });

      test('userType should return farmer for FarmerProfileResponse', () {
        final response = FarmerProfileResponse(farmerProfile);

        expect(response.userType, UserType.farmer);
      });

      test('userType should return merchant for MerchantProfileResponse', () {
        final response = MerchantProfileResponse(merchantProfile);

        expect(response.userType, UserType.merchant);
      });

      test(
        'createdAt should return correct timestamp for FarmerProfileResponse',
        () {
          final response = FarmerProfileResponse(farmerProfile);

          expect(response.createdAt, testDate);
        },
      );

      test(
        'createdAt should return correct timestamp for MerchantProfileResponse',
        () {
          final response = MerchantProfileResponse(merchantProfile);

          expect(response.createdAt, testDate);
        },
      );

      test(
        'updatedAt should return correct timestamp for FarmerProfileResponse',
        () {
          final response = FarmerProfileResponse(farmerProfile);

          expect(response.updatedAt, testDate);
        },
      );

      test(
        'updatedAt should return correct timestamp for MerchantProfileResponse',
        () {
          final response = MerchantProfileResponse(merchantProfile);

          expect(response.updatedAt, testDate);
        },
      );
    });

    group('Pattern matching', () {
      test('should support switch expressions for FarmerProfileResponse', () {
        final response =
            FarmerProfileResponse(farmerProfile) as ProfileResponse;

        final result = switch (response) {
          FarmerProfileResponse(profile: final p) => 'Farmer: ${p.village}',
          MerchantProfileResponse(profile: final p) =>
            'Merchant: ${p.businessName}',
        };

        expect(result, 'Farmer: Pandamatenga');
      });

      test('should support switch expressions for MerchantProfileResponse', () {
        final response =
            MerchantProfileResponse(merchantProfile) as ProfileResponse;

        final result = switch (response) {
          FarmerProfileResponse(profile: final p) => 'Farmer: ${p.village}',
          MerchantProfileResponse(profile: final p) =>
            'Merchant: ${p.businessName}',
        };

        expect(result, 'Merchant: Agri Supplies');
      });
    });

    group('Type checking', () {
      test('should be able to check if response is FarmerProfileResponse', () {
        final response =
            FarmerProfileResponse(farmerProfile) as ProfileResponse;

        expect(response is FarmerProfileResponse, isTrue);
        expect(response is MerchantProfileResponse, isFalse);
      });

      test(
        'should be able to check if response is MerchantProfileResponse',
        () {
          final response =
              MerchantProfileResponse(merchantProfile) as ProfileResponse;

          expect(response is MerchantProfileResponse, isTrue);
          expect(response is FarmerProfileResponse, isFalse);
        },
      );
    });
  });
}
