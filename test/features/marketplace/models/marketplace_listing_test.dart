import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleJson = {
    'id': 42,
    'title': 'Fresh Maize',
    'description': 'Organic maize from Gaborone',
    'type': 'produce',
    'category': 'cereals',
    'price': 25.5,
    'unit': 'kg',
    'sellerName': 'John Farmer',
    'sellerId': 'user-123',
    'location': 'Gaborone',
    'status': 'harvested',
    'harvestDate': '2026-03-01',
    'quantity': '100',
    'imagePath': 'https://example.com/maize.jpg',
    'sellerPhone': '+26712345678',
    'sellerEmail': 'john@example.com',
    'additionalImages': ['img1.jpg', 'img2.jpg'],
    'inventoryId': 99,
    'createdAt': '2026-03-15T10:00:00.000',
  };

  group('MarketplaceListing.fromJson', () {
    test('parses all fields correctly', () {
      final listing = MarketplaceListing.fromJson(sampleJson);

      expect(listing.id, '42'); // int → String via requiredString
      expect(listing.title, 'Fresh Maize');
      expect(listing.description, 'Organic maize from Gaborone');
      expect(listing.type, ListingType.produce);
      expect(listing.category, 'cereals');
      expect(listing.price, 25.5);
      expect(listing.unit, 'kg');
      expect(listing.sellerName, 'John Farmer');
      expect(listing.sellerId, 'user-123');
      expect(listing.location, 'Gaborone');
      expect(listing.status, CropStatus.harvested);
      expect(listing.harvestDate, '2026-03-01');
      expect(listing.quantity, '100');
      expect(listing.imagePath, 'https://example.com/maize.jpg');
      expect(listing.sellerPhone, '+26712345678');
      expect(listing.sellerEmail, 'john@example.com');
      expect(listing.additionalImages, ['img1.jpg', 'img2.jpg']);
      expect(listing.inventoryId, '99'); // int → String via optionalString
      expect(listing.createdAt, DateTime.parse('2026-03-15T10:00:00.000'));
    });

    test('handles null optional fields', () {
      final json = {
        ...sampleJson,
        'price': null,
        'unit': null,
        'status': null,
        'harvestDate': null,
        'quantity': null,
        'imagePath': null,
        'sellerPhone': null,
        'sellerEmail': null,
        'additionalImages': null,
        'inventoryId': null,
      };
      final listing = MarketplaceListing.fromJson(json);

      expect(listing.price, isNull);
      expect(listing.unit, isNull);
      expect(listing.status, isNull);
      expect(listing.harvestDate, isNull);
      expect(listing.quantity, isNull);
      expect(listing.imagePath, isNull);
      expect(listing.sellerPhone, isNull);
      expect(listing.sellerEmail, isNull);
      expect(listing.additionalImages, isNull);
      expect(listing.inventoryId, isNull);
    });

    test('handles string id', () {
      final json = {...sampleJson, 'id': 'abc-123'};
      expect(MarketplaceListing.fromJson(json).id, 'abc-123');
    });

    test('type enum defaults to produce for unknown value', () {
      final json = {...sampleJson, 'type': 'unknown_type'};
      expect(MarketplaceListing.fromJson(json).type, ListingType.produce);
    });

    test('status enum defaults to harvested for unknown value', () {
      final json = {...sampleJson, 'status': 'unknown_status'};
      expect(MarketplaceListing.fromJson(json).status, CropStatus.harvested);
    });

    test('price handles integer value', () {
      final json = {...sampleJson, 'price': 100};
      expect(MarketplaceListing.fromJson(json).price, 100.0);
    });

    test('createdAt defaults to now when null', () {
      final before = DateTime.now();
      final json = {...sampleJson, 'createdAt': null};
      final listing = MarketplaceListing.fromJson(json);
      final after = DateTime.now();

      expect(listing.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(listing.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('MarketplaceListing.toJson', () {
    test('produces correct map', () {
      final listing = MarketplaceListing.fromJson(sampleJson);
      final json = listing.toJson();

      expect(json['id'], '42');
      expect(json['title'], 'Fresh Maize');
      expect(json['type'], 'produce');
      expect(json['status'], 'harvested');
      expect(json['price'], 25.5);
      expect(json['additionalImages'], ['img1.jpg', 'img2.jpg']);
      expect(json['createdAt'], isA<String>());
    });

    test('round-trip preserves data', () {
      final listing = MarketplaceListing.fromJson(sampleJson);
      final roundTripped = MarketplaceListing.fromJson(listing.toJson());

      expect(roundTripped.id, listing.id);
      expect(roundTripped.title, listing.title);
      expect(roundTripped.description, listing.description);
      expect(roundTripped.type, listing.type);
      expect(roundTripped.category, listing.category);
      expect(roundTripped.price, listing.price);
      expect(roundTripped.sellerName, listing.sellerName);
      expect(roundTripped.sellerId, listing.sellerId);
      expect(roundTripped.location, listing.location);
      expect(roundTripped.status, listing.status);
      expect(roundTripped.inventoryId, listing.inventoryId);
    });

    test('null optionals stay null', () {
      final json = {
        ...sampleJson,
        'price': null,
        'status': null,
        'additionalImages': null,
      };
      final output = MarketplaceListing.fromJson(json).toJson();

      expect(output['price'], isNull);
      expect(output['status'], isNull);
      expect(output['additionalImages'], isNull);
    });
  });

  group('copyWith', () {
    test('overrides specified fields only', () {
      final original = MarketplaceListing.fromJson(sampleJson);
      final copy = original.copyWith(title: 'Updated Title', price: 50.0);

      expect(copy.title, 'Updated Title');
      expect(copy.price, 50.0);
      expect(copy.id, original.id);
      expect(copy.description, original.description);
      expect(copy.sellerName, original.sellerName);
    });

    test('can override id', () {
      final original = MarketplaceListing.fromJson(sampleJson);
      expect(original.copyWith(id: 'new-id').id, 'new-id');
    });
  });

  group('computed properties', () {
    test('isAvailableNow true for harvested', () {
      final listing = MarketplaceListing.fromJson(
        {...sampleJson, 'status': 'harvested'},
      );
      expect(listing.isAvailableNow, isTrue);
    });

    test('isAvailableNow true for readyToHarvest', () {
      final listing = MarketplaceListing.fromJson(
        {...sampleJson, 'status': 'readyToHarvest'},
      );
      expect(listing.isAvailableNow, isTrue);
    });

    test('isAvailableNow false for planted', () {
      final listing = MarketplaceListing.fromJson(
        {...sampleJson, 'status': 'planted'},
      );
      expect(listing.isAvailableNow, isFalse);
    });

    test('isAvailableNow false for growing', () {
      final listing = MarketplaceListing.fromJson(
        {...sampleJson, 'status': 'growing'},
      );
      expect(listing.isAvailableNow, isFalse);
    });

    test('isProduce and isSupplies', () {
      final produce = MarketplaceListing.fromJson(sampleJson);
      expect(produce.isProduce, isTrue);
      expect(produce.isSupplies, isFalse);

      final supplies = MarketplaceListing.fromJson(
        {...sampleJson, 'type': 'supplies'},
      );
      expect(supplies.isProduce, isFalse);
      expect(supplies.isSupplies, isTrue);
    });
  });
}
