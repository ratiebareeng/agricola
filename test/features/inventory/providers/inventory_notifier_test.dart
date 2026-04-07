import 'package:agricola/core/services/analytics_service.dart';
import 'package:agricola/features/inventory/data/inventory_offline_repository.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInventoryOfflineRepository extends Mock
    implements InventoryOfflineRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

InventoryModel _makeItem({String? id, String cropType = 'maize'}) {
  return InventoryModel(
    id: id,
    cropType: cropType,
    quantity: 100,
    unit: 'kg',
    storageDate: DateTime(2026),
    storageLocation: 'Warehouse',
    condition: 'good',
  );
}

void main() {
  late MockInventoryOfflineRepository mockRepo;
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockRepo = MockInventoryOfflineRepository();
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logInventoryAdded(itemName: any(named: 'itemName')))
        .thenAnswer((_) async {});
  });

  /// Helper: creates a notifier that does NOT auto-load on init.
  /// We stub getUserInventory to return empty by default so the constructor
  /// call doesn't throw, then we can test individual methods.
  InventoryNotifier createNotifier({
    List<InventoryModel> initialData = const [],
  }) {
    when(() => mockRepo.getUserInventory())
        .thenAnswer((_) async => initialData);
    return InventoryNotifier(mockRepo, mockAnalytics);
  }

  /// Wait for the constructor's loadInventory() to settle.
  Future<void> waitForLoad(InventoryNotifier notifier) async {
    // Give the async constructor call time to complete
    await Future<void>.delayed(Duration.zero);
  }

  group('loadInventory', () {
    test('sets data on success', () async {
      final items = [_makeItem(id: '1'), _makeItem(id: '2')];
      final notifier = createNotifier(initialData: items);

      await waitForLoad(notifier);

      expect(notifier.state, isA<AsyncData<List<InventoryModel>>>());
      expect(notifier.state.value!.length, 2);
    });

    test('sets error on failure', () async {
      when(() => mockRepo.getUserInventory())
          .thenThrow(Exception('Network error'));
      final notifier = InventoryNotifier(mockRepo, mockAnalytics);

      await waitForLoad(notifier);

      expect(notifier.state, isA<AsyncError<List<InventoryModel>>>());
    });
  });

  group('addInventory', () {
    test('prepends item and returns null on success', () async {
      final notifier = createNotifier(
        initialData: [_makeItem(id: '1')],
      );
      await waitForLoad(notifier);

      final newItem = _makeItem(cropType: 'beans');
      final created = newItem.copyWith(id: '2');
      when(() => mockRepo.createInventory(newItem))
          .thenAnswer((_) async => created);

      final result = await notifier.addInventory(newItem);

      expect(result, isNull);
      expect(notifier.state.value!.length, 2);
      expect(notifier.state.value!.first.id, '2');
    });

    test('returns error string on failure', () async {
      final notifier = createNotifier();
      await waitForLoad(notifier);

      final newItem = _makeItem();
      when(() => mockRepo.createInventory(newItem))
          .thenThrow(Exception('Create failed'));

      final result = await notifier.addInventory(newItem);

      expect(result, contains('Create failed'));
      expect(notifier.state.value, isEmpty);
    });
  });

  group('updateInventory', () {
    test('replaces matching item and returns null on success', () async {
      final notifier = createNotifier(
        initialData: [_makeItem(id: '1', cropType: 'maize')],
      );
      await waitForLoad(notifier);

      final updated = _makeItem(id: '1', cropType: 'sorghum');
      when(() => mockRepo.updateInventory('1', updated))
          .thenAnswer((_) async => updated);

      final result = await notifier.updateInventory(updated);

      expect(result, isNull);
      expect(notifier.state.value!.first.cropType, 'sorghum');
      expect(notifier.state.value!.length, 1);
    });

    test('returns error string on failure', () async {
      final notifier = createNotifier(
        initialData: [_makeItem(id: '1')],
      );
      await waitForLoad(notifier);

      final updated = _makeItem(id: '1', cropType: 'sorghum');
      when(() => mockRepo.updateInventory('1', updated))
          .thenThrow(Exception('Update failed'));

      final result = await notifier.updateInventory(updated);

      expect(result, contains('Update failed'));
      expect(notifier.state.value!.first.cropType, 'maize');
    });
  });

  group('deleteInventory', () {
    test('removes item and returns null on success', () async {
      final notifier = createNotifier(
        initialData: [_makeItem(id: '1'), _makeItem(id: '2')],
      );
      await waitForLoad(notifier);

      when(() => mockRepo.deleteInventory('1')).thenAnswer((_) async {});

      final result = await notifier.deleteInventory('1');

      expect(result, isNull);
      expect(notifier.state.value!.length, 1);
      expect(notifier.state.value!.first.id, '2');
    });

    test('returns error string on failure', () async {
      final notifier = createNotifier(
        initialData: [_makeItem(id: '1')],
      );
      await waitForLoad(notifier);

      when(() => mockRepo.deleteInventory('1'))
          .thenThrow(Exception('Delete failed'));

      final result = await notifier.deleteInventory('1');

      expect(result, contains('Delete failed'));
      expect(notifier.state.value!.length, 1);
    });
  });
}
