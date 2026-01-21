import 'package:agricola/core/constants/validation_rules.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile/utils/profile_validators.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileValidators', () {
    group('validateFarmerProfile', () {
      test('returns null for valid farmer profile', () {
        final profile = FarmerProfileModel(
          id: '1',
          userId: 'user123',
          village: 'Test Village',
          primaryCrops: ['Maize', 'Beans'],
          farmSize: 'Small (< 5 acres)',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(ProfileValidators.validateFarmerProfile(profile), null);
      });

      test('returns error when village is empty', () {
        final profile = FarmerProfileModel(
          id: '1',
          userId: 'user123',
          village: '',
          primaryCrops: ['Maize'],
          farmSize: 'Small (< 5 acres)',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateFarmerProfile(profile),
          ValidationRules.villageRequired,
        );
      });

      test('returns error when village is too short', () {
        final profile = FarmerProfileModel(
          id: '1',
          userId: 'user123',
          village: 'A',
          primaryCrops: ['Maize'],
          farmSize: 'Small (< 5 acres)',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateFarmerProfile(profile),
          ValidationRules.villageRequired,
        );
      });

      test('returns error when primaryCrops is empty', () {
        final profile = FarmerProfileModel(
          id: '1',
          userId: 'user123',
          village: 'Test Village',
          primaryCrops: [],
          farmSize: 'Small (< 5 acres)',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateFarmerProfile(profile),
          ValidationRules.cropsRequired,
        );
      });

      test('returns error when primaryCrops exceeds max count', () {
        final profile = FarmerProfileModel(
          id: '1',
          userId: 'user123',
          village: 'Test Village',
          primaryCrops: [
            'Maize',
            'Beans',
            'Rice',
            'Wheat',
            'Sorghum',
            'Millet',
          ],
          farmSize: 'Small (< 5 acres)',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateFarmerProfile(profile),
          'Select up to ${ValidationRules.maxPrimaryCropsCount} crops',
        );
      });

      test('returns error when farmSize is empty', () {
        final profile = FarmerProfileModel(
          id: '1',
          userId: 'user123',
          village: 'Test Village',
          primaryCrops: ['Maize'],
          farmSize: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateFarmerProfile(profile),
          ValidationRules.farmSizeRequired,
        );
      });
    });

    group('validateMerchantProfile', () {
      test('returns null for valid merchant profile', () {
        final profile = MerchantProfileModel(
          id: '1',
          userId: 'user123',
          merchantType: MerchantType.agriShop,
          businessName: 'Test Business',
          location: 'Gaborone',
          productsOffered: ['Maize', 'Beans'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(ProfileValidators.validateMerchantProfile(profile), null);
      });

      test('returns error when businessName is too short', () {
        final profile = MerchantProfileModel(
          id: '1',
          userId: 'user123',
          merchantType: MerchantType.agriShop,
          businessName: 'AB',
          location: 'Gaborone',
          productsOffered: ['Maize'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateMerchantProfile(profile),
          ValidationRules.businessNameTooShort,
        );
      });

      test('returns error when businessName is too long', () {
        final profile = MerchantProfileModel(
          id: '1',
          userId: 'user123',
          merchantType: MerchantType.agriShop,
          businessName: 'A' * 101,
          location: 'Gaborone',
          productsOffered: ['Maize'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateMerchantProfile(profile),
          ValidationRules.businessNameTooLong,
        );
      });

      test('returns error when location is empty', () {
        final profile = MerchantProfileModel(
          id: '1',
          userId: 'user123',
          merchantType: MerchantType.agriShop,
          businessName: 'Test Business',
          location: '',
          productsOffered: ['Maize'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateMerchantProfile(profile),
          ValidationRules.villageRequired,
        );
      });

      test('returns error when location is too short', () {
        final profile = MerchantProfileModel(
          id: '1',
          userId: 'user123',
          merchantType: MerchantType.agriShop,
          businessName: 'Test Business',
          location: 'A',
          productsOffered: ['Maize'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          ProfileValidators.validateMerchantProfile(profile),
          ValidationRules.villageRequired,
        );
      });
    });

    group('validateBusinessName', () {
      test('returns null for valid business name', () {
        expect(ProfileValidators.validateBusinessName('Test Business'), null);
      });

      test('returns error for null value', () {
        expect(
          ProfileValidators.validateBusinessName(null),
          'Business name is required',
        );
      });

      test('returns error for empty value', () {
        expect(
          ProfileValidators.validateBusinessName(''),
          'Business name is required',
        );
      });

      test('returns error for too short value', () {
        expect(
          ProfileValidators.validateBusinessName('AB'),
          ValidationRules.businessNameTooShort,
        );
      });

      test('returns error for too long value', () {
        expect(
          ProfileValidators.validateBusinessName('A' * 101),
          ValidationRules.businessNameTooLong,
        );
      });
    });

    group('validateVillage', () {
      test('returns null for valid village', () {
        expect(ProfileValidators.validateVillage('Test Village'), null);
      });

      test('returns error for null value', () {
        expect(
          ProfileValidators.validateVillage(null),
          ValidationRules.villageRequired,
        );
      });

      test('returns error for empty value', () {
        expect(
          ProfileValidators.validateVillage(''),
          ValidationRules.villageRequired,
        );
      });

      test('returns error for too short value', () {
        expect(
          ProfileValidators.validateVillage('A'),
          'Village name too short',
        );
      });
    });

    group('validateCrops', () {
      test('returns null for valid crops list', () {
        expect(ProfileValidators.validateCrops(['Maize', 'Beans']), null);
      });

      test('returns error for empty list', () {
        expect(
          ProfileValidators.validateCrops([]),
          ValidationRules.cropsRequired,
        );
      });

      test('returns error when crops exceed max count', () {
        final crops = ['Maize', 'Beans', 'Rice', 'Wheat', 'Sorghum', 'Millet'];
        expect(
          ProfileValidators.validateCrops(crops),
          'Select up to ${ValidationRules.maxPrimaryCropsCount} crops',
        );
      });

      test('accepts exactly max crops count', () {
        final crops = ['Maize', 'Beans', 'Rice', 'Wheat', 'Sorghum'];
        expect(ProfileValidators.validateCrops(crops), null);
      });
    });
  });
}
