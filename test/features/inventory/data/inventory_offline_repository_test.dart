import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/core/database/daos/inventory_local_dao.dart';
import 'package:agricola/features/inventory/data/inventory_api_service.dart';
import 'package:agricola/features/inventory/data/inventory_offline_repository.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInventoryApiService extends Mock implements InventoryApiService {}

class MockInventoryLocalDao extends Mock implements InventoryLocalDao {}

class MockAppDatabase extends Mock implements AppDatabase {}

class FakeInventoryModel extends Fake implements InventoryModel {}

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
  late MockInventoryApiService mockApi;
  late MockInventoryLocalDao mockDao;
  late MockAppDatabase mockDb;

  setUp(() {
    mockApi = MockInventoryApiService();
    mockDao = MockInventoryLocalDao();
    mockDb = MockAppDatabase();
  });

  setUpAll(() {
    registerFallbackValue(FakeInventoryModel());
  });

  InventoryOfflineRepository createRepo({
    required bool isOnline,
    required bool offlineEnabled,
  }) {
    return InventoryOfflineRepository(
      apiService: mockApi,
      localDao: mockDao,
      db: mockDb,
      isOnline: () => isOnline,
      offlineEnabled: () => offlineEnabled,
    );
  }

  group('getUserInventory', () {
    final items = [_makeItem(id: '1'), _makeItem(id: '2')];

    test('offline disabled: calls API only', () async {
      final repo = createRepo(isOnline: true, offlineEnabled: false);
      when(() => mockApi.getUserInventory()).thenAnswer((_) async => items);

      final result = await repo.getUserInventory();

      expect(result.length, 2);
      verify(() => mockApi.getUserInventory()).called(1);
      verifyNever(() => mockDao.cacheAll(any()));
    });

    test('online + offline enabled: calls API and caches locally', () async {
      final repo = createRepo(isOnline: true, offlineEnabled: true);
      when(() => mockApi.getUserInventory()).thenAnswer((_) async => items);
      when(() => mockDao.cacheAll(any())).thenAnswer((_) async {});

      final result = await repo.getUserInventory();

      expect(result.length, 2);
      verify(() => mockApi.getUserInventory()).called(1);
      verify(() => mockDao.cacheAll(items)).called(1);
    });

    test('online + offline enabled + API fails: falls back to local', () async {
      final repo = createRepo(isOnline: true, offlineEnabled: true);
      when(() => mockApi.getUserInventory()).thenThrow(Exception('timeout'));
      when(() => mockDao.getAll()).thenAnswer((_) async => items);

      final result = await repo.getUserInventory();

      expect(result.length, 2);
      verify(() => mockDao.getAll()).called(1);
    });

    test('offline: returns local data', () async {
      final repo = createRepo(isOnline: false, offlineEnabled: true);
      when(() => mockDao.getAll()).thenAnswer((_) async => items);

      final result = await repo.getUserInventory();

      expect(result.length, 2);
      verifyNever(() => mockApi.getUserInventory());
      verify(() => mockDao.getAll()).called(1);
    });
  });

  group('createInventory', () {
    final newItem = _makeItem();
    final created = newItem.copyWith(id: '10');

    test('offline disabled: API only', () async {
      final repo = createRepo(isOnline: true, offlineEnabled: false);
      when(() => mockApi.createInventory(newItem))
          .thenAnswer((_) async => created);

      final result = await repo.createInventory(newItem);

      expect(result.id, '10');
      verify(() => mockApi.createInventory(newItem)).called(1);
      verifyNever(() => mockDao.upsertOne(any()));
    });

    test('online + offline enabled: API + caches locally', () async {
      final repo = createRepo(isOnline: true, offlineEnabled: true);
      when(() => mockApi.createInventory(newItem))
          .thenAnswer((_) async => created);
      when(() => mockDao.upsertOne(any())).thenAnswer((_) async {});

      final result = await repo.createInventory(newItem);

      expect(result.id, '10');
      verify(() => mockApi.createInventory(newItem)).called(1);
      verify(() => mockDao.upsertOne(created)).called(1);
    });

    test('offline: creates local item with local_ prefix and adds to sync queue', () async {
      final repo = createRepo(isOnline: false, offlineEnabled: true);
      when(() => mockDao.upsertOne(
        any(),
        isSynced: any(named: 'isSynced'),
        localId: any(named: 'localId'),
      )).thenAnswer((_) async {});
      when(() => mockDb.addToSyncQueue(
        entityType: any(named: 'entityType'),
        localId: any(named: 'localId'),
        operation: any(named: 'operation'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async => 1);

      final result = await repo.createInventory(newItem);

      expect(result.id, startsWith('local_'));
      verify(() => mockDao.upsertOne(
        any(),
        isSynced: false,
        localId: any(named: 'localId'),
      )).called(1);
      verify(() => mockDb.addToSyncQueue(
        entityType: 'inventory',
        localId: any(named: 'localId'),
        operation: 'create',
        payload: any(named: 'payload'),
      )).called(1);
    });
  });

  group('updateInventory', () {
    final item = _makeItem(id: '5', cropType: 'sorghum');
    final updated = item.copyWith(cropType: 'beans');

    test('online: API + caches', () async {
      final repo = createRepo(isOnline: true, offlineEnabled: true);
      when(() => mockApi.updateInventory('5', item))
          .thenAnswer((_) async => updated);
      when(() => mockDao.upsertOne(any())).thenAnswer((_) async {});

      final result = await repo.updateInventory('5', item);

      expect(result.cropType, 'beans');
      verify(() => mockApi.updateInventory('5', item)).called(1);
      verify(() => mockDao.upsertOne(updated)).called(1);
    });

    test('offline: local update + sync queue', () async {
      final repo = createRepo(isOnline: false, offlineEnabled: true);
      when(() => mockDao.upsertOne(any(), isSynced: any(named: 'isSynced')))
          .thenAnswer((_) async {});
      when(() => mockDb.addToSyncQueue(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        localId: any(named: 'localId'),
        operation: any(named: 'operation'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async => 1);

      final result = await repo.updateInventory('5', item);

      expect(result.id, '5');
      verify(() => mockDao.upsertOne(any(), isSynced: false)).called(1);
      verify(() => mockDb.addToSyncQueue(
        entityType: 'inventory',
        entityId: '5',
        localId: '5',
        operation: 'update',
        payload: any(named: 'payload'),
      )).called(1);
    });
  });

  group('deleteInventory', () {
    test('online: API + local delete', () async {
      final repo = createRepo(isOnline: true, offlineEnabled: true);
      when(() => mockApi.deleteInventory('5')).thenAnswer((_) async {});
      when(() => mockDao.deleteOne('5')).thenAnswer((_) async {});

      await repo.deleteInventory('5');

      verify(() => mockApi.deleteInventory('5')).called(1);
      verify(() => mockDao.deleteOne('5')).called(1);
    });

    test('offline with server ID: local delete + sync queue', () async {
      final repo = createRepo(isOnline: false, offlineEnabled: true);
      when(() => mockDao.deleteOne('5')).thenAnswer((_) async {});
      when(() => mockDb.addToSyncQueue(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        localId: any(named: 'localId'),
        operation: any(named: 'operation'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async => 1);

      await repo.deleteInventory('5');

      verify(() => mockDao.deleteOne('5')).called(1);
      verify(() => mockDb.addToSyncQueue(
        entityType: 'inventory',
        entityId: '5',
        localId: '5',
        operation: 'delete',
        payload: {},
      )).called(1);
    });

    test('offline with local_ ID: local delete only, no sync queue', () async {
      final repo = createRepo(isOnline: false, offlineEnabled: true);
      when(() => mockDao.deleteOne('local_abc')).thenAnswer((_) async {});

      await repo.deleteInventory('local_abc');

      verify(() => mockDao.deleteOne('local_abc')).called(1);
      verifyNever(() => mockDb.addToSyncQueue(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        localId: any(named: 'localId'),
        operation: any(named: 'operation'),
        payload: any(named: 'payload'),
      ));
    });
  });
}
