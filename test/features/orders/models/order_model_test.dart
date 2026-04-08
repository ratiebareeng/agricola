import 'package:agricola/features/orders/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared fixtures
  // ---------------------------------------------------------------------------

  final sampleItemJson = {
    'listingId': 'listing-1',
    'title': 'Fresh Maize',
    'price': 25.50,
    'quantity': 10,
  };

  final sampleOrderJson = {
    'id': '42',
    'userId': 'user-uid-123',
    'sellerId': 'seller-uid-456',
    'status': 'pending',
    'totalAmount': 255.0,
    'items': [sampleItemJson],
    'createdAt': '2026-01-15T10:00:00.000',
    'updatedAt': '2026-01-15T12:00:00.000',
  };

  // ---------------------------------------------------------------------------
  // OrderItem
  // ---------------------------------------------------------------------------

  group('OrderItem.fromJson', () {
    test('parses all fields correctly', () {
      final item = OrderItem.fromJson(sampleItemJson);

      expect(item.listingId, 'listing-1');
      expect(item.title, 'Fresh Maize');
      expect(item.price, 25.50);
      expect(item.quantity, 10);
    });

    test('handles int price via (num).toDouble()', () {
      final json = {...sampleItemJson, 'price': 25};
      final item = OrderItem.fromJson(json);

      expect(item.price, 25.0);
      expect(item.price, isA<double>());
    });
  });

  group('OrderItem.toJson', () {
    test('produces correct map', () {
      final item = OrderItem.fromJson(sampleItemJson);
      final json = item.toJson();

      expect(json['listingId'], 'listing-1');
      expect(json['title'], 'Fresh Maize');
      expect(json['price'], 25.50);
      expect(json['quantity'], 10);
    });

    test('round-trip preserves data', () {
      final item = OrderItem.fromJson(sampleItemJson);
      final roundTripped = OrderItem.fromJson(item.toJson());

      expect(roundTripped.listingId, item.listingId);
      expect(roundTripped.title, item.title);
      expect(roundTripped.price, item.price);
      expect(roundTripped.quantity, item.quantity);
    });
  });

  group('OrderItem.copyWith', () {
    test('overrides specified fields only', () {
      final original = OrderItem.fromJson(sampleItemJson);
      final copy = original.copyWith(quantity: 5, price: 30.0);

      expect(copy.quantity, 5);
      expect(copy.price, 30.0);
      expect(copy.listingId, original.listingId);
      expect(copy.title, original.title);
    });
  });

  // ---------------------------------------------------------------------------
  // OrderModel
  // ---------------------------------------------------------------------------

  group('OrderModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = OrderModel.fromJson(sampleOrderJson);

      expect(model.id, '42');
      expect(model.userId, 'user-uid-123');
      expect(model.sellerId, 'seller-uid-456');
      expect(model.status, 'pending');
      expect(model.totalAmount, 255.0);
      expect(model.items.length, 1);
      expect(model.items.first.title, 'Fresh Maize');
      expect(model.createdAt, DateTime.parse('2026-01-15T10:00:00.000'));
      expect(model.updatedAt, DateTime.parse('2026-01-15T12:00:00.000'));
    });

    test('handles int id via optionalString', () {
      final json = {...sampleOrderJson, 'id': 42};
      final model = OrderModel.fromJson(json);

      expect(model.id, '42');
    });

    test('handles null id', () {
      final json = {...sampleOrderJson, 'id': null};
      final model = OrderModel.fromJson(json);

      expect(model.id, isNull);
    });

    test('handles int totalAmount via (num).toDouble()', () {
      final json = {...sampleOrderJson, 'totalAmount': 255};
      final model = OrderModel.fromJson(json);

      expect(model.totalAmount, 255.0);
      expect(model.totalAmount, isA<double>());
    });

    test('parses empty items list', () {
      final json = {...sampleOrderJson, 'items': <dynamic>[]};
      final model = OrderModel.fromJson(json);

      expect(model.items, isEmpty);
    });

    test('parses multiple items', () {
      final secondItem = {
        'listingId': 'listing-2',
        'title': 'Sunflower Oil',
        'price': 45.0,
        'quantity': 2,
      };
      final json = {
        ...sampleOrderJson,
        'items': [sampleItemJson, secondItem],
      };
      final model = OrderModel.fromJson(json);

      expect(model.items.length, 2);
      expect(model.items[1].title, 'Sunflower Oil');
    });
  });

  group('OrderModel.toJson', () {
    test('produces correct map', () {
      final model = OrderModel.fromJson(sampleOrderJson);
      final json = model.toJson();

      expect(json['id'], '42');
      expect(json['userId'], 'user-uid-123');
      expect(json['sellerId'], 'seller-uid-456');
      expect(json['status'], 'pending');
      expect(json['totalAmount'], 255.0);
      expect(json['items'], isA<List>());
      expect((json['items'] as List).length, 1);
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
    });

    test('includes id when non-null', () {
      final model = OrderModel.fromJson(sampleOrderJson);
      expect(model.toJson().containsKey('id'), isTrue);
    });

    test('excludes id when null', () {
      final json = {...sampleOrderJson, 'id': null};
      final model = OrderModel.fromJson(json);
      expect(model.toJson().containsKey('id'), isFalse);
    });

    test('round-trip preserves data', () {
      final model = OrderModel.fromJson(sampleOrderJson);
      final roundTripped = OrderModel.fromJson(model.toJson());

      expect(roundTripped.id, model.id);
      expect(roundTripped.userId, model.userId);
      expect(roundTripped.sellerId, model.sellerId);
      expect(roundTripped.status, model.status);
      expect(roundTripped.totalAmount, model.totalAmount);
      expect(roundTripped.items.length, model.items.length);
      expect(roundTripped.createdAt, model.createdAt);
      expect(roundTripped.updatedAt, model.updatedAt);
    });
  });

  group('OrderModel.copyWith', () {
    test('overrides specified fields only', () {
      final original = OrderModel.fromJson(sampleOrderJson);
      final copy = original.copyWith(status: 'confirmed', totalAmount: 300.0);

      expect(copy.status, 'confirmed');
      expect(copy.totalAmount, 300.0);
      expect(copy.id, original.id);
      expect(copy.userId, original.userId);
      expect(copy.sellerId, original.sellerId);
      expect(copy.items, original.items);
    });
  });

  group('OrderModel constructor defaults', () {
    test('createdAt and updatedAt default to approximately now', () {
      final before = DateTime.now();
      final model = OrderModel(
        userId: 'user-1',
        sellerId: 'seller-1',
        status: 'pending',
        totalAmount: 100.0,
        items: const [],
      );
      final after = DateTime.now();

      expect(
        model.createdAt
            .isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        model.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        model.updatedAt
            .isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });
}
