import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleJson = {
    'id': 42,
    'cropType': 'maize',
    'quantity': 100.5,
    'unit': 'kg',
    'storageDate': '2026-01-15T00:00:00.000',
    'storageLocation': 'Warehouse A',
    'condition': 'good',
    'notes': 'First batch',
    'createdAt': '2026-01-15T10:00:00.000',
    'updatedAt': '2026-01-15T12:00:00.000',
  };

  group('InventoryModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = InventoryModel.fromJson(sampleJson);

      expect(model.id, '42'); // int → String via optionalString
      expect(model.cropType, 'maize');
      expect(model.quantity, 100.5);
      expect(model.unit, 'kg');
      expect(model.storageDate, DateTime.parse('2026-01-15T00:00:00.000'));
      expect(model.storageLocation, 'Warehouse A');
      expect(model.condition, 'good');
      expect(model.notes, 'First batch');
      expect(model.createdAt, DateTime.parse('2026-01-15T10:00:00.000'));
      expect(model.updatedAt, DateTime.parse('2026-01-15T12:00:00.000'));
    });

    test('handles string id', () {
      final json = {...sampleJson, 'id': 'abc-123'};
      expect(InventoryModel.fromJson(json).id, 'abc-123');
    });

    test('handles null id and notes', () {
      final json = {...sampleJson, 'id': null, 'notes': null};
      final model = InventoryModel.fromJson(json);
      expect(model.id, isNull);
      expect(model.notes, isNull);
    });

    test('handles integer quantity', () {
      final json = {...sampleJson, 'quantity': 100};
      expect(InventoryModel.fromJson(json).quantity, 100.0);
    });
  });

  group('InventoryModel.toJson', () {
    test('produces correct map', () {
      final model = InventoryModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], '42');
      expect(json['cropType'], 'maize');
      expect(json['quantity'], 100.5);
      expect(json['unit'], 'kg');
      expect(json['storageLocation'], 'Warehouse A');
      expect(json['condition'], 'good');
      expect(json['notes'], 'First batch');
      expect(json['storageDate'], isA<String>());
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
    });

    test('round-trip preserves data', () {
      final model = InventoryModel.fromJson(sampleJson);
      final roundTripped = InventoryModel.fromJson(model.toJson());

      expect(roundTripped.id, model.id);
      expect(roundTripped.cropType, model.cropType);
      expect(roundTripped.quantity, model.quantity);
      expect(roundTripped.unit, model.unit);
      expect(roundTripped.storageDate, model.storageDate);
      expect(roundTripped.storageLocation, model.storageLocation);
      expect(roundTripped.condition, model.condition);
      expect(roundTripped.notes, model.notes);
    });
  });

  group('copyWith', () {
    test('overrides specified fields only', () {
      final original = InventoryModel.fromJson(sampleJson);
      final copy = original.copyWith(quantity: 200.0, condition: 'fair');

      expect(copy.quantity, 200.0);
      expect(copy.condition, 'fair');
      expect(copy.id, original.id);
      expect(copy.cropType, original.cropType);
      expect(copy.unit, original.unit);
      expect(copy.storageLocation, original.storageLocation);
      expect(copy.notes, original.notes);
    });

    test('can override id', () {
      final original = InventoryModel.fromJson(sampleJson);
      final copy = original.copyWith(id: 'new-id');
      expect(copy.id, 'new-id');
    });
  });

  group('constructor defaults', () {
    test('createdAt and updatedAt default to approximately now', () {
      final before = DateTime.now();
      final model = InventoryModel(
        cropType: 'beans',
        quantity: 50,
        unit: 'kg',
        storageDate: DateTime(2026),
        storageLocation: 'Silo',
        condition: 'good',
      );
      final after = DateTime.now();

      expect(model.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(model.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(model.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
    });
  });
}
