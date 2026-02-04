import 'package:agricola/features/marketplace/models/marketplace_listing.dart';

class MarketplaceFilter {
  final String searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final ListingType? itemType;
  final String? category;

  const MarketplaceFilter({
    this.searchQuery = '',
    this.minPrice,
    this.maxPrice,
    this.itemType,
    this.category,
  });

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      category != null;

  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (category != null) count++;
    return count;
  }

  MarketplaceFilter copyWith({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    ListingType? itemType,
    String? category,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCategory = false,
  }) {
    return MarketplaceFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      itemType: itemType ?? this.itemType,
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (searchQuery.isNotEmpty) 'search': searchQuery,
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      if (itemType != null) 'type': itemType!.name,
      if (category != null) 'category': category,
    };
  }
}
