import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toQueryParameters', () {
    test('empty filter produces empty map', () {
      const filter = MarketplaceFilter();
      expect(filter.toQueryParameters(), isEmpty);
    });

    test('populated filter produces correct pairs', () {
      const filter = MarketplaceFilter(
        searchQuery: 'maize',
        minPrice: 10.0,
        maxPrice: 50.0,
        itemType: ListingType.produce,
        category: 'cereals',
        sellerId: 'user-1',
      );
      final params = filter.toQueryParameters();

      expect(params['search'], 'maize');
      expect(params['minPrice'], '10.0');
      expect(params['maxPrice'], '50.0');
      expect(params['type'], 'produce');
      expect(params['category'], 'cereals');
      expect(params['sellerId'], 'user-1');
    });

    test('partial filter includes only set keys', () {
      const filter = MarketplaceFilter(
        searchQuery: 'beans',
        category: 'legumes',
      );
      final params = filter.toQueryParameters();

      expect(params.length, 2);
      expect(params['search'], 'beans');
      expect(params['category'], 'legumes');
      expect(params.containsKey('minPrice'), isFalse);
      expect(params.containsKey('type'), isFalse);
    });
  });

  group('hasActiveFilters', () {
    test('default filter returns false', () {
      expect(const MarketplaceFilter().hasActiveFilters, isFalse);
    });

    test('with searchQuery returns true', () {
      expect(
        const MarketplaceFilter(searchQuery: 'maize').hasActiveFilters,
        isTrue,
      );
    });

    test('with minPrice returns true', () {
      expect(
        const MarketplaceFilter(minPrice: 10).hasActiveFilters,
        isTrue,
      );
    });

    test('with category returns true', () {
      expect(
        const MarketplaceFilter(category: 'cereals').hasActiveFilters,
        isTrue,
      );
    });
  });

  group('activeFilterCount', () {
    test('default is 0', () {
      expect(const MarketplaceFilter().activeFilterCount, 0);
    });

    test('price range counts as 1', () {
      expect(
        const MarketplaceFilter(minPrice: 10, maxPrice: 50).activeFilterCount,
        1,
      );
    });

    test('category + price counts as 2', () {
      expect(
        const MarketplaceFilter(minPrice: 10, category: 'cereals')
            .activeFilterCount,
        2,
      );
    });
  });

  group('copyWith', () {
    test('overrides specified fields', () {
      const original = MarketplaceFilter(searchQuery: 'maize', minPrice: 10);
      final copy = original.copyWith(searchQuery: 'beans');

      expect(copy.searchQuery, 'beans');
      expect(copy.minPrice, 10);
    });

    test('clearMinPrice sets to null', () {
      const original = MarketplaceFilter(minPrice: 10, maxPrice: 50);
      final copy = original.copyWith(clearMinPrice: true);

      expect(copy.minPrice, isNull);
      expect(copy.maxPrice, 50);
    });

    test('clearCategory sets to null', () {
      const original = MarketplaceFilter(category: 'cereals');
      final copy = original.copyWith(clearCategory: true);

      expect(copy.category, isNull);
    });

    test('clearSellerId sets to null', () {
      const original = MarketplaceFilter(sellerId: 'user-1');
      final copy = original.copyWith(clearSellerId: true);

      expect(copy.sellerId, isNull);
    });
  });
}
