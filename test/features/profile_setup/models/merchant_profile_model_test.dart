import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MerchantType', () {
    group('displayName', () {
      test('should return correct display name for agriShop', () {
        expect(MerchantType.agriShop.displayName, 'Agri Shop');
      });

      test('should return correct display name for supermarketVendor', () {
        expect(
          MerchantType.supermarketVendor.displayName,
          'Supermarket Vendor',
        );
      });

      test('should return correct display name for nursery', () {
        expect(MerchantType.nursery.displayName, 'Nursery');
      });

      test('should return correct display name for vetClinic', () {
        expect(MerchantType.vetClinic.displayName, 'Vet Clinic');
      });

      test('should return correct display name for feedSupplier', () {
        expect(MerchantType.feedSupplier.displayName, 'Feed Supplier');
      });

      test('should return correct display name for equipmentSupplier', () {
        expect(
          MerchantType.equipmentSupplier.displayName,
          'Equipment Supplier',
        );
      });

      test('should return correct display name for transportService', () {
        expect(MerchantType.transportService.displayName, 'Transport Service');
      });

      test('should return correct display name for processingUnit', () {
        expect(MerchantType.processingUnit.displayName, 'Processing Unit');
      });

      test('should return correct display name for other', () {
        expect(MerchantType.other.displayName, 'Other');
      });
    });

    group('fromString', () {
      test('should parse valid merchant type strings', () {
        expect(MerchantType.fromString('agriShop'), MerchantType.agriShop);
        expect(
          MerchantType.fromString('supermarketVendor'),
          MerchantType.supermarketVendor,
        );
        expect(MerchantType.fromString('nursery'), MerchantType.nursery);
        expect(MerchantType.fromString('vetClinic'), MerchantType.vetClinic);
        expect(
          MerchantType.fromString('feedSupplier'),
          MerchantType.feedSupplier,
        );
        expect(
          MerchantType.fromString('equipmentSupplier'),
          MerchantType.equipmentSupplier,
        );
        expect(
          MerchantType.fromString('transportService'),
          MerchantType.transportService,
        );
        expect(
          MerchantType.fromString('processingUnit'),
          MerchantType.processingUnit,
        );
        expect(MerchantType.fromString('other'), MerchantType.other);
      });

      test('should return other for invalid string', () {
        expect(MerchantType.fromString('invalid'), MerchantType.other);
        expect(MerchantType.fromString(''), MerchantType.other);
        expect(MerchantType.fromString('AGRISH0P'), MerchantType.other);
      });
    });
  });

  group('MerchantProfileModel', () {
    final testDate = DateTime(2026, 1, 21, 10, 30);

    final testProfile = MerchantProfileModel(
      id: 'merchant-id-123',
      userId: 'user-456',
      merchantType: MerchantType.agriShop,
      businessName: 'Pandamatenga Agri Supplies',
      location: 'Pandamatenga',
      customLocation: null,
      productsOffered: ['Seeds', 'Fertilizer', 'Tools'],
      photoUrl: 'https://example.com/shop-photo.jpg',
      createdAt: testDate,
      updatedAt: testDate,
    );

    group('constructor', () {
      test('should create instance with required fields', () {
        expect(testProfile.id, 'merchant-id-123');
        expect(testProfile.userId, 'user-456');
        expect(testProfile.merchantType, MerchantType.agriShop);
        expect(testProfile.businessName, 'Pandamatenga Agri Supplies');
        expect(testProfile.location, 'Pandamatenga');
        expect(testProfile.customLocation, isNull);
        expect(testProfile.productsOffered, ['Seeds', 'Fertilizer', 'Tools']);
        expect(testProfile.photoUrl, 'https://example.com/shop-photo.jpg');
        expect(testProfile.createdAt, testDate);
        expect(testProfile.updatedAt, testDate);
      });

      test('should create instance with custom location', () {
        final profile = MerchantProfileModel(
          id: 'merchant-id',
          userId: 'user-456',
          merchantType: MerchantType.nursery,
          businessName: 'Green Thumb Nursery',
          location: 'Other',
          customLocation: 'Near Main Road',
          productsOffered: ['Plants', 'Seeds'],
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile.customLocation, 'Near Main Road');
        expect(profile.photoUrl, isNull);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'merchant-id-123',
          'userId': 'user-456',
          'merchantType': 'agriShop',
          'businessName': 'Pandamatenga Agri Supplies',
          'location': 'Pandamatenga',
          'customLocation': null,
          'productsOffered': ['Seeds', 'Fertilizer', 'Tools'],
          'photoUrl': 'https://example.com/shop-photo.jpg',
          'createdAt': '2026-01-21T10:30:00.000',
          'updatedAt': '2026-01-21T10:30:00.000',
        };

        final profile = MerchantProfileModel.fromJson(json);

        expect(profile.id, 'merchant-id-123');
        expect(profile.userId, 'user-456');
        expect(profile.merchantType, MerchantType.agriShop);
        expect(profile.businessName, 'Pandamatenga Agri Supplies');
        expect(profile.location, 'Pandamatenga');
        expect(profile.customLocation, isNull);
        expect(profile.productsOffered, ['Seeds', 'Fertilizer', 'Tools']);
        expect(profile.photoUrl, 'https://example.com/shop-photo.jpg');
        expect(profile.createdAt, DateTime(2026, 1, 21, 10, 30));
        expect(profile.updatedAt, DateTime(2026, 1, 21, 10, 30));
      });

      test('should handle null photoUrl', () {
        final json = {
          'id': 'merchant-id',
          'userId': 'user-456',
          'merchantType': 'nursery',
          'businessName': 'Test Business',
          'location': 'Kasane',
          'customLocation': null,
          'productsOffered': ['Plants'],
          'photoUrl': null,
          'createdAt': '2026-01-21T10:30:00.000',
          'updatedAt': '2026-01-21T10:30:00.000',
        };

        final profile = MerchantProfileModel.fromJson(json);

        expect(profile.photoUrl, isNull);
      });

      test('should handle empty productsOffered array', () {
        final json = {
          'id': 'merchant-id',
          'userId': 'user-456',
          'merchantType': 'agriShop',
          'businessName': 'Test Business',
          'location': 'Pandamatenga',
          'customLocation': null,
          'productsOffered': [],
          'photoUrl': null,
          'createdAt': '2026-01-21T10:30:00.000',
          'updatedAt': '2026-01-21T10:30:00.000',
        };

        final profile = MerchantProfileModel.fromJson(json);

        expect(profile.productsOffered, isEmpty);
      });

      test('should handle missing productsOffered field', () {
        final json = {
          'id': 'merchant-id',
          'userId': 'user-456',
          'merchantType': 'vetClinic',
          'businessName': 'Vet Clinic',
          'location': 'Kasane',
          'customLocation': null,
          'photoUrl': null,
          'createdAt': '2026-01-21T10:30:00.000',
          'updatedAt': '2026-01-21T10:30:00.000',
        };

        final profile = MerchantProfileModel.fromJson(json);

        expect(profile.productsOffered, isEmpty);
      });

      test('should parse all merchant types correctly', () {
        final types = [
          'agriShop',
          'supermarketVendor',
          'nursery',
          'vetClinic',
          'feedSupplier',
          'equipmentSupplier',
          'transportService',
          'processingUnit',
          'other',
        ];

        for (final type in types) {
          final json = {
            'id': 'merchant-id',
            'userId': 'user-456',
            'merchantType': type,
            'businessName': 'Test Business',
            'location': 'Test Location',
            'customLocation': null,
            'productsOffered': ['Product'],
            'photoUrl': null,
            'createdAt': '2026-01-21T10:30:00.000',
            'updatedAt': '2026-01-21T10:30:00.000',
          };

          final profile = MerchantProfileModel.fromJson(json);
          expect(profile.merchantType.name, type);
        }
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final json = testProfile.toJson();

        expect(json['id'], 'merchant-id-123');
        expect(json['userId'], 'user-456');
        expect(json['merchantType'], 'agriShop');
        expect(json['businessName'], 'Pandamatenga Agri Supplies');
        expect(json['location'], 'Pandamatenga');
        expect(json['customLocation'], isNull);
        expect(json['productsOffered'], ['Seeds', 'Fertilizer', 'Tools']);
        expect(json['photoUrl'], 'https://example.com/shop-photo.jpg');
        expect(json['createdAt'], '2026-01-21T10:30:00.000');
        expect(json['updatedAt'], '2026-01-21T10:30:00.000');
      });

      test('should serialize null values correctly', () {
        final profile = MerchantProfileModel(
          id: 'merchant-id',
          userId: 'user-456',
          merchantType: MerchantType.nursery,
          businessName: 'Test Business',
          location: 'Kasane',
          productsOffered: ['Plants'],
          createdAt: testDate,
          updatedAt: testDate,
        );

        final json = profile.toJson();

        expect(json['customLocation'], isNull);
        expect(json['photoUrl'], isNull);
      });
    });

    group('toCreateRequest', () {
      test('should create request payload without id and timestamps', () {
        final request = testProfile.toCreateRequest();

        expect(request.containsKey('id'), isFalse);
        expect(request.containsKey('createdAt'), isFalse);
        expect(request.containsKey('updatedAt'), isFalse);
        expect(request['userId'], 'user-456');
        expect(request['merchantType'], 'agriShop');
        expect(request['businessName'], 'Pandamatenga Agri Supplies');
        expect(request['location'], 'Pandamatenga');
        expect(request['customLocation'], isNull);
        expect(request['productsOffered'], ['Seeds', 'Fertilizer', 'Tools']);
        expect(request['photoUrl'], 'https://example.com/shop-photo.jpg');
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
          expect(request['merchantType'], 'agriShop');
          expect(request['businessName'], 'Pandamatenga Agri Supplies');
          expect(request['location'], 'Pandamatenga');
          expect(request['customLocation'], isNull);
          expect(request['productsOffered'], ['Seeds', 'Fertilizer', 'Tools']);
          expect(request['photoUrl'], 'https://example.com/shop-photo.jpg');
        },
      );
    });

    group('displayLocation', () {
      test('should return location when not Other', () {
        expect(testProfile.displayLocation, 'Pandamatenga');
      });

      test('should return customLocation when location is Other', () {
        final profile = MerchantProfileModel(
          id: 'merchant-id',
          userId: 'user-456',
          merchantType: MerchantType.agriShop,
          businessName: 'Test Business',
          location: 'Other',
          customLocation: 'Near Airport',
          productsOffered: ['Products'],
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile.displayLocation, 'Near Airport');
      });

      test(
        'should return Other when location is Other and customLocation is null',
        () {
          final profile = MerchantProfileModel(
            id: 'merchant-id',
            userId: 'user-456',
            merchantType: MerchantType.agriShop,
            businessName: 'Test Business',
            location: 'Other',
            productsOffered: ['Products'],
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
          businessName: 'New Business Name',
          location: 'Kasane',
          merchantType: MerchantType.nursery,
          photoUrl: 'https://example.com/new-photo.jpg',
        );

        expect(updatedProfile.id, testProfile.id);
        expect(updatedProfile.userId, testProfile.userId);
        expect(updatedProfile.businessName, 'New Business Name');
        expect(updatedProfile.location, 'Kasane');
        expect(updatedProfile.merchantType, MerchantType.nursery);
        expect(updatedProfile.productsOffered, testProfile.productsOffered);
        expect(updatedProfile.photoUrl, 'https://example.com/new-photo.jpg');
      });

      test('should copy with no changes when no parameters provided', () {
        final copiedProfile = testProfile.copyWith();

        expect(copiedProfile, testProfile);
      });

      test('should copy with new productsOffered list', () {
        final updatedProfile = testProfile.copyWith(
          productsOffered: ['New Product 1', 'New Product 2'],
        );

        expect(updatedProfile.productsOffered, [
          'New Product 1',
          'New Product 2',
        ]);
        expect(updatedProfile.id, testProfile.id);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are equal', () {
        final profile1 = MerchantProfileModel(
          id: 'merchant-id',
          userId: 'user-456',
          merchantType: MerchantType.agriShop,
          businessName: 'Test Business',
          location: 'Pandamatenga',
          productsOffered: ['Seeds'],
          createdAt: testDate,
          updatedAt: testDate,
        );

        final profile2 = MerchantProfileModel(
          id: 'merchant-id',
          userId: 'user-456',
          merchantType: MerchantType.agriShop,
          businessName: 'Test Business',
          location: 'Pandamatenga',
          productsOffered: ['Seeds'],
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile1, profile2);
        expect(profile1.hashCode, profile2.hashCode);
      });

      test('should not be equal when properties differ', () {
        final profile1 = MerchantProfileModel(
          id: 'merchant-id-1',
          userId: 'user-456',
          merchantType: MerchantType.agriShop,
          businessName: 'Test Business',
          location: 'Pandamatenga',
          productsOffered: ['Seeds'],
          createdAt: testDate,
          updatedAt: testDate,
        );

        final profile2 = MerchantProfileModel(
          id: 'merchant-id-2',
          userId: 'user-456',
          merchantType: MerchantType.agriShop,
          businessName: 'Test Business',
          location: 'Pandamatenga',
          productsOffered: ['Seeds'],
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile1, isNot(profile2));
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through serialization cycle', () {
        final json = testProfile.toJson();
        final deserializedProfile = MerchantProfileModel.fromJson(json);

        expect(deserializedProfile, testProfile);
      });
    });
  });
}
