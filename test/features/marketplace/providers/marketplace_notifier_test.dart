import 'package:agricola/core/database/daos/marketplace_local_dao.dart';
import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/core/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/marketplace/data/marketplace_api_service.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketplaceApiService extends Mock
    implements MarketplaceApiService {}

class MockMarketplaceLocalDao extends Mock implements MarketplaceLocalDao {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class FakeMarketplaceListing extends Fake implements MarketplaceListing {}

MarketplaceListing _makeListing({
  String id = '1',
  String title = 'Fresh Maize',
  CropStatus status = CropStatus.harvested,
  DateTime? createdAt,
}) {
  return MarketplaceListing(
    id: id,
    title: title,
    description: 'Test listing',
    type: ListingType.produce,
    category: 'cereals',
    price: 25.0,
    unit: 'kg',
    sellerName: 'John',
    sellerId: 'user-1',
    location: 'Gaborone',
    status: status,
    createdAt: createdAt ?? DateTime(2026, 3, 15),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMarketplaceApiService mockApi;
  late MockMarketplaceLocalDao mockDao;
  late MockAnalyticsService mockAnalytics;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApi = MockMarketplaceApiService();
    mockDao = MockMarketplaceLocalDao();
    mockAnalytics = MockAnalyticsService();

    when(() => mockAnalytics.logListingCreated()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        // Override the current user to null (avoids Firebase)
        currentUserProvider.overrideWithValue(null),
        // Override connectivity/offline settings
        isOnlineProvider.overrideWithValue(true),
        offlineModeEnabledProvider.overrideWith((ref) {
          final notifier = OfflineModeNotifier();
          return notifier;
        }),
        // Override API service and DAO
        marketplaceApiServiceProvider.overrideWithValue(mockApi),
        marketplaceLocalDaoProvider.overrideWithValue(mockDao),
        // Override analytics
        analyticsServiceProvider.overrideWithValue(mockAnalytics),
        // Override profile setup to provide a user type
        profileSetupProvider.overrideWith((ref) {
          final notifier = ProfileSetupNotifier(ref);
          // Default: farmer user type (sees supplies)
          return notifier;
        }),
      ],
    );
  });

  setUpAll(() {
    registerFallbackValue(FakeMarketplaceListing());
    registerFallbackValue(<MarketplaceListing>[]);
  });

  tearDown(() {
    container.dispose();
  });

  /// Wait for the constructor's loadListings() to settle.
  Future<void> waitForLoad() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  group('loadListings', () {
    test('sets data on success', () async {
      final items = [_makeListing(id: '1'), _makeListing(id: '2')];
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenAnswer((_) async => items);

      // Reading the notifier provider triggers construction + loadListings
      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      final state = container.read(marketplaceNotifierProvider);
      expect(state, isA<AsyncData<List<MarketplaceListing>>>());
      expect(state.value!.length, 2);
    });

    test('sorts available items first', () async {
      final items = [
        _makeListing(
          id: '1',
          status: CropStatus.planted,
          createdAt: DateTime(2026, 3, 20),
        ),
        _makeListing(
          id: '2',
          status: CropStatus.harvested,
          createdAt: DateTime(2026, 3, 10),
        ),
      ];
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenAnswer((_) async => items);

      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      final state = container.read(marketplaceNotifierProvider);
      // Harvested (available) should be first despite older date
      expect(state.value!.first.id, '2');
      expect(state.value!.last.id, '1');
    });

    test('sets error when API fails and no cache', () async {
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenThrow(Exception('Network error'));

      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      final state = container.read(marketplaceNotifierProvider);
      expect(state, isA<AsyncError<List<MarketplaceListing>>>());
    });
  });

  group('loadListings (offline)', () {
    late ProviderContainer offlineContainer;

    setUp(() {
      offlineContainer = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          isOnlineProvider.overrideWithValue(false),
          offlineModeEnabledProvider.overrideWith((ref) {
            final notifier = OfflineModeNotifier();
            notifier.setEnabled(true);
            return notifier;
          }),
          marketplaceApiServiceProvider.overrideWithValue(mockApi),
          marketplaceLocalDaoProvider.overrideWithValue(mockDao),
          analyticsServiceProvider.overrideWithValue(mockAnalytics),
          profileSetupProvider
              .overrideWith((ref) => ProfileSetupNotifier(ref)),
        ],
      );
    });

    tearDown(() => offlineContainer.dispose());

    test('returns local data when offline', () async {
      final cached = [_makeListing(id: '1')];
      when(() => mockDao.getAll()).thenAnswer((_) async => cached);

      offlineContainer.read(marketplaceNotifierProvider);
      await waitForLoad();

      final state = offlineContainer.read(marketplaceNotifierProvider);
      expect(state.value!.length, 1);
      verifyNever(() => mockApi.getListings(filter: any(named: 'filter')));
      verify(() => mockDao.getAll()).called(1);
    });
  });

  group('loadListings (online + offline enabled, API fails)', () {
    late ProviderContainer fallbackContainer;

    setUp(() {
      fallbackContainer = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          isOnlineProvider.overrideWithValue(true),
          offlineModeEnabledProvider.overrideWith((ref) {
            final notifier = OfflineModeNotifier();
            notifier.setEnabled(true);
            return notifier;
          }),
          marketplaceApiServiceProvider.overrideWithValue(mockApi),
          marketplaceLocalDaoProvider.overrideWithValue(mockDao),
          analyticsServiceProvider.overrideWithValue(mockAnalytics),
          profileSetupProvider
              .overrideWith((ref) => ProfileSetupNotifier(ref)),
        ],
      );
    });

    tearDown(() => fallbackContainer.dispose());

    test('falls back to local cache on API error', () async {
      final cached = [_makeListing(id: '1')];
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenThrow(Exception('timeout'));
      when(() => mockDao.getAll()).thenAnswer((_) async => cached);

      fallbackContainer.read(marketplaceNotifierProvider);
      await waitForLoad();

      final state = fallbackContainer.read(marketplaceNotifierProvider);
      expect(state.value!.length, 1);
      verify(() => mockDao.getAll()).called(1);
    });
  });

  group('addListing', () {
    test('prepends listing and returns null on success', () async {
      final existing = [_makeListing(id: '1')];
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenAnswer((_) async => existing);

      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      final newListing = _makeListing(id: '2', title: 'Beans');
      when(() => mockApi.createListing(any()))
          .thenAnswer((_) async => newListing);

      final notifier =
          container.read(marketplaceNotifierProvider.notifier);
      final result = await notifier.addListing(newListing);

      expect(result, isNull);
      final state = container.read(marketplaceNotifierProvider);
      expect(state.value!.length, 2);
      expect(state.value!.first.id, '2');
    });

    test('returns error key on failure', () async {
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenAnswer((_) async => []);

      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      when(() => mockApi.createListing(any()))
          .thenThrow(Exception('Create failed'));

      final notifier =
          container.read(marketplaceNotifierProvider.notifier);
      final result = await notifier.addListing(_makeListing());

      expect(result, equals('error_unexpected'));
    });
  });

  group('updateListing', () {
    test('replaces matching listing and returns null on success', () async {
      final existing = [_makeListing(id: '1', title: 'Maize')];
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenAnswer((_) async => existing);

      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      final updated = _makeListing(id: '1', title: 'Sorghum');
      when(() => mockApi.updateListing('1', any()))
          .thenAnswer((_) async => updated);

      final notifier =
          container.read(marketplaceNotifierProvider.notifier);
      final result = await notifier.updateListing(updated);

      expect(result, isNull);
      expect(
        container.read(marketplaceNotifierProvider).value!.first.title,
        'Sorghum',
      );
    });

    test('returns error key on failure', () async {
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenAnswer((_) async => [_makeListing(id: '1')]);

      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      when(() => mockApi.updateListing('1', any()))
          .thenThrow(Exception('Update failed'));

      final notifier =
          container.read(marketplaceNotifierProvider.notifier);
      final result =
          await notifier.updateListing(_makeListing(id: '1'));

      expect(result, equals('error_unexpected'));
    });
  });

  group('deleteListing', () {
    test('removes listing and returns null on success', () async {
      final existing = [
        _makeListing(id: '1'),
        _makeListing(id: '2'),
      ];
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenAnswer((_) async => existing);

      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      when(() => mockApi.deleteListing('1')).thenAnswer((_) async {});

      final notifier =
          container.read(marketplaceNotifierProvider.notifier);
      final result = await notifier.deleteListing('1');

      expect(result, isNull);
      final state = container.read(marketplaceNotifierProvider);
      expect(state.value!.length, 1);
      expect(state.value!.first.id, '2');
    });

    test('returns error key on failure', () async {
      when(() => mockApi.getListings(filter: any(named: 'filter')))
          .thenAnswer((_) async => [_makeListing(id: '1')]);

      container.read(marketplaceNotifierProvider);
      await waitForLoad();

      when(() => mockApi.deleteListing('1'))
          .thenThrow(Exception('Delete failed'));

      final notifier =
          container.read(marketplaceNotifierProvider.notifier);
      final result = await notifier.deleteListing('1');

      expect(result, equals('error_unexpected'));
    });
  });
}
