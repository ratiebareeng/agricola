import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FarmerProfileModel', () {
    final testDate = DateTime(2026, 1, 21, 10, 30);

    final testProfile = FarmerProfileModel(
      id: 'test-id-123',
      userId: 'user-123',
      village: 'Pandamatenga',
      customVillage: null,
      primaryCrops: ['Maize', 'Sorghum', 'Beans'],
      farmSize: '5-10 hectares',
      photoUrl: 'https://example.com/photo.jpg',
      createdAt: testDate,
      updatedAt: testDate,
    );

    group('constructor', () {
      test('should create instance with required fields', () {
        expect(testProfile.id, 'test-id-123');
        expect(testProfile.userId, 'user-123');
        expect(testProfile.village, 'Pandamatenga');
        expect(testProfile.customVillage, isNull);
        expect(testProfile.primaryCrops, ['Maize', 'Sorghum', 'Beans']);
        expect(testProfile.farmSize, '5-10 hectares');
        expect(testProfile.photoUrl, 'https://example.com/photo.jpg');
        expect(testProfile.createdAt, testDate);
        expect(testProfile.updatedAt, testDate);
      });

      test('should create instance with custom village', () {
        final profile = FarmerProfileModel(
          id: 'test-id',
          userId: 'user-123',
          village: 'Other',
          customVillage: 'Custom Village Name',
          primaryCrops: ['Maize'],
          farmSize: '1-5 hectares',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile.customVillage, 'Custom Village Name');
        expect(profile.photoUrl, isNull);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'test-id-123',
          'userId': 'user-123',
          'village': 'Pandamatenga',
          'customVillage': null,
          'primaryCrops': ['Maize', 'Sorghum', 'Beans'],
          'farmSize': '5-10 hectares',
          'photoUrl': 'https://example.com/photo.jpg',
          'createdAt': '2026-01-21T10:30:00.000',
          'updatedAt': '2026-01-21T10:30:00.000',
        };

        final profile = FarmerProfileModel.fromJson(json);

        expect(profile.id, 'test-id-123');
        expect(profile.userId, 'user-123');
        expect(profile.village, 'Pandamatenga');
        expect(profile.customVillage, isNull);
        expect(profile.primaryCrops, ['Maize', 'Sorghum', 'Beans']);
        expect(profile.farmSize, '5-10 hectares');
        expect(profile.photoUrl, 'https://example.com/photo.jpg');
        expect(profile.createdAt, DateTime(2026, 1, 21, 10, 30));
        expect(profile.updatedAt, DateTime(2026, 1, 21, 10, 30));
      });

      test('should handle null photoUrl', () {
        final json = {
          'id': 'test-id',
          'userId': 'user-123',
          'village': 'Pandamatenga',
          'customVillage': null,
          'primaryCrops': ['Maize'],
          'farmSize': '1-5 hectares',
          'photoUrl': null,
          'createdAt': '2026-01-21T10:30:00.000',
          'updatedAt': '2026-01-21T10:30:00.000',
        };

        final profile = FarmerProfileModel.fromJson(json);

        expect(profile.photoUrl, isNull);
      });

      test('should handle empty primaryCrops array', () {
        final json = {
          'id': 'test-id',
          'userId': 'user-123',
          'village': 'Pandamatenga',
          'customVillage': null,
          'primaryCrops': [],
          'farmSize': '1-5 hectares',
          'photoUrl': null,
          'createdAt': '2026-01-21T10:30:00.000',
          'updatedAt': '2026-01-21T10:30:00.000',
        };

        final profile = FarmerProfileModel.fromJson(json);

        expect(profile.primaryCrops, isEmpty);
      });

      test('should handle missing primaryCrops field', () {
        final json = {
          'id': 'test-id',
          'userId': 'user-123',
          'village': 'Pandamatenga',
          'customVillage': null,
          'farmSize': '1-5 hectares',
          'photoUrl': null,
          'createdAt': '2026-01-21T10:30:00.000',
          'updatedAt': '2026-01-21T10:30:00.000',
        };

        final profile = FarmerProfileModel.fromJson(json);

        expect(profile.primaryCrops, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final json = testProfile.toJson();

        expect(json['id'], 'test-id-123');
        expect(json['userId'], 'user-123');
        expect(json['village'], 'Pandamatenga');
        expect(json['customVillage'], isNull);
        expect(json['primaryCrops'], ['Maize', 'Sorghum', 'Beans']);
        expect(json['farmSize'], '5-10 hectares');
        expect(json['photoUrl'], 'https://example.com/photo.jpg');
        expect(json['createdAt'], '2026-01-21T10:30:00.000');
        expect(json['updatedAt'], '2026-01-21T10:30:00.000');
      });

      test('should serialize null values correctly', () {
        final profile = FarmerProfileModel(
          id: 'test-id',
          userId: 'user-123',
          village: 'Pandamatenga',
          primaryCrops: ['Maize'],
          farmSize: '1-5 hectares',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final json = profile.toJson();

        expect(json['customVillage'], isNull);
        expect(json['photoUrl'], isNull);
      });
    });

    group('toCreateRequest', () {
      test('should create request payload without id and timestamps', () {
        final request = testProfile.toCreateRequest();

        expect(request.containsKey('id'), isFalse);
        expect(request.containsKey('createdAt'), isFalse);
        expect(request.containsKey('updatedAt'), isFalse);
        expect(request['userId'], 'user-123');
        expect(request['village'], 'Pandamatenga');
        expect(request['customVillage'], isNull);
        expect(request['primaryCrops'], ['Maize', 'Sorghum', 'Beans']);
        expect(request['farmSize'], '5-10 hectares');
        expect(request['photoUrl'], 'https://example.com/photo.jpg');
      });
    });

    group('toUpdateRequest', () {
      test(
        'should create update payload without id, userId and timestamps',
        () {
          final request = testProfile.toUpdateRequest();

          expect(request.containsKey('id'), isFalse);
          expect(request.containsKey('userId'), isFalse);
          expect(request.containsKey('createdAt'), isFalse);
          expect(request.containsKey('updatedAt'), isFalse);
          expect(request['village'], 'Pandamatenga');
          expect(request['customVillage'], isNull);
          expect(request['primaryCrops'], ['Maize', 'Sorghum', 'Beans']);
          expect(request['farmSize'], '5-10 hectares');
          expect(request['photoUrl'], 'https://example.com/photo.jpg');
        },
      );
    });

    group('displayLocation', () {
      test('should return village when not Other', () {
        expect(testProfile.displayLocation, 'Pandamatenga');
      });

      test('should return customVillage when village is Other', () {
        final profile = FarmerProfileModel(
          id: 'test-id',
          userId: 'user-123',
          village: 'Other',
          customVillage: 'My Custom Village',
          primaryCrops: ['Maize'],
          farmSize: '1-5 hectares',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile.displayLocation, 'My Custom Village');
      });

      test(
        'should return Other when village is Other and customVillage is null',
        () {
          final profile = FarmerProfileModel(
            id: 'test-id',
            userId: 'user-123',
            village: 'Other',
            primaryCrops: ['Maize'],
            farmSize: '1-5 hectares',
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(profile.displayLocation, 'Other');
        },
      );
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final updatedProfile = testProfile.copyWith(
          village: 'Kasane',
          farmSize: '10-20 hectares',
          photoUrl: 'https://example.com/new-photo.jpg',
        );

        expect(updatedProfile.id, testProfile.id);
        expect(updatedProfile.userId, testProfile.userId);
        expect(updatedProfile.village, 'Kasane');
        expect(updatedProfile.primaryCrops, testProfile.primaryCrops);
        expect(updatedProfile.farmSize, '10-20 hectares');
        expect(updatedProfile.photoUrl, 'https://example.com/new-photo.jpg');
      });

      test('should copy with no changes when no parameters provided', () {
        final copiedProfile = testProfile.copyWith();

        expect(copiedProfile, testProfile);
      });

      test('should copy with new primaryCrops list', () {
        final updatedProfile = testProfile.copyWith(
          primaryCrops: ['Wheat', 'Barley'],
        );

        expect(updatedProfile.primaryCrops, ['Wheat', 'Barley']);
        expect(updatedProfile.id, testProfile.id);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are equal', () {
        final profile1 = FarmerProfileModel(
          id: 'test-id',
          userId: 'user-123',
          village: 'Pandamatenga',
          primaryCrops: ['Maize'],
          farmSize: '1-5 hectares',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final profile2 = FarmerProfileModel(
          id: 'test-id',
          userId: 'user-123',
          village: 'Pandamatenga',
          primaryCrops: ['Maize'],
          farmSize: '1-5 hectares',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile1, profile2);
        expect(profile1.hashCode, profile2.hashCode);
      });

      test('should not be equal when properties differ', () {
        final profile1 = FarmerProfileModel(
          id: 'test-id-1',
          userId: 'user-123',
          village: 'Pandamatenga',
          primaryCrops: ['Maize'],
          farmSize: '1-5 hectares',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final profile2 = FarmerProfileModel(
          id: 'test-id-2',
          userId: 'user-123',
          village: 'Pandamatenga',
          primaryCrops: ['Maize'],
          farmSize: '1-5 hectares',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile1, isNot(profile2));
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through serialization cycle', () {
        final json = testProfile.toJson();
        final deserializedProfile = FarmerProfileModel.fromJson(json);

        expect(deserializedProfile, testProfile);
      });
    });
  });
}
