import 'package:agricola/features/marketplace/models/marketplace_listing.dart';

class MarketplaceFilter {
  final String searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final ListingType? itemType;
  final String? category;
  final String? sellerId;

  const MarketplaceFilter({
    this.searchQuery = '',
    this.minPrice,
    this.maxPrice,
    this.itemType,
    this.category,
    this.sellerId,
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
    String? sellerId,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCategory = false,
    bool clearSellerId = false,
  }) {
    return MarketplaceFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      itemType: itemType ?? this.itemType,
      category: clearCategory ? null : (category ?? this.category),
      sellerId: clearSellerId ? null : (sellerId ?? this.sellerId),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (searchQuery.isNotEmpty) 'search': searchQuery,
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      if (itemType != null) 'type': itemType!.name,
      if (category != null) 'category': category,
      if (sellerId != null) 'sellerId': sellerId,
    };
  }
}
