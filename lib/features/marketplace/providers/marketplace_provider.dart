import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
      return MarketplaceNotifier();
    });

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  MarketplaceNotifier() : super(MarketplaceState()) {
    _initializeMockData();
  }

  void clearSearch({UserType? userType, MerchantType? merchantType}) {
    List<MarketplaceListing> filtered = List.from(state.allListings);

    if (userType == UserType.farmer) {
      filtered = filtered.where((l) => l.type == ListingType.supplies).toList();
    } else if (userType == UserType.merchant) {
      filtered = filtered.where((l) => l.type == ListingType.produce).toList();
    }

    filtered.sort((a, b) {
      if (a.isAvailableNow && !b.isAvailableNow) return -1;
      if (!a.isAvailableNow && b.isAvailableNow) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    state = state.copyWith(filteredListings: filtered, searchQuery: '');
  }

  void filterByCategory(String category) {
    if (category.isEmpty) {
      state = state.copyWith(
        filteredListings: state.allListings,
        selectedCategory: null,
      );
      return;
    }

    final filtered = state.allListings
        .where((listing) => listing.category == category)
        .toList();

    state = state.copyWith(
      filteredListings: filtered,
      selectedCategory: category,
    );
  }

  void initializeForUserType({UserType? userType, MerchantType? merchantType}) {
    List<MarketplaceListing> filtered = List.from(state.allListings);

    if (userType == UserType.farmer) {
      filtered = filtered.where((l) => l.type == ListingType.supplies).toList();
    } else if (userType == UserType.merchant) {
      filtered = filtered.where((l) => l.type == ListingType.produce).toList();
    }

    filtered.sort((a, b) {
      if (a.isAvailableNow && !b.isAvailableNow) return -1;
      if (!a.isAvailableNow && b.isAvailableNow) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    state = state.copyWith(filteredListings: filtered);
  }

  void search(String query, {UserType? userType, MerchantType? merchantType}) {
    if (query.isEmpty) {
      state = state.copyWith(
        filteredListings: state.allListings,
        searchQuery: '',
      );
      return;
    }

    final queryLower = query.toLowerCase();
    List<MarketplaceListing> results = state.allListings.where((listing) {
      final titleMatch = listing.title.toLowerCase().contains(queryLower);
      final descMatch = listing.description.toLowerCase().contains(queryLower);
      final categoryMatch = listing.category.toLowerCase().contains(queryLower);
      return titleMatch || descMatch || categoryMatch;
    }).toList();

    if (userType == UserType.farmer) {
      results = results.where((l) => l.type == ListingType.supplies).toList();
    } else if (userType == UserType.merchant) {
      results = results.where((l) => l.type == ListingType.produce).toList();
    }

    results.sort((a, b) {
      if (a.isAvailableNow && !b.isAvailableNow) return -1;
      if (!a.isAvailableNow && b.isAvailableNow) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    state = state.copyWith(filteredListings: results, searchQuery: query);
  }

  void _initializeMockData() {
    final mockListings = <MarketplaceListing>[
      MarketplaceListing(
        id: '1',
        title: 'Fresh Maize',
        description: 'High quality maize, just harvested',
        type: ListingType.produce,
        category: 'Grains',
        price: 45.0,
        unit: 'per 50kg bag',
        sellerName: 'Thabo Molefe',
        sellerId: 'farmer1',
        location: 'Molepolole',
        status: CropStatus.harvested,
        quantity: '200 bags',
        sellerPhone: '+267 7234 5678',
        sellerEmail: 'thabo.molefe@email.com',
      ),
      MarketplaceListing(
        id: '2',
        title: 'Organic Tomatoes',
        description: 'Fresh organic tomatoes ready for pickup',
        type: ListingType.produce,
        category: 'Vegetables',
        price: 25.0,
        unit: 'per crate',
        sellerName: 'Kefilwe Kgosi',
        sellerId: 'farmer2',
        location: 'Gaborone',
        status: CropStatus.harvested,
        quantity: '50 crates',
        sellerPhone: '+267 7556 7890',
      ),
      MarketplaceListing(
        id: '3',
        title: 'Watermelons',
        description: 'Sweet watermelons, ready to harvest next week',
        type: ListingType.produce,
        category: 'Fruits',
        price: 35.0,
        unit: 'per unit',
        sellerName: 'Mpho Motse',
        sellerId: 'farmer3',
        location: 'Palapye',
        status: CropStatus.readyToHarvest,
        harvestDate: '2026-01-08',
        quantity: '300 units',
        sellerPhone: '+267 7345 6789',
        sellerEmail: 'mpho.motse@email.com',
      ),
      MarketplaceListing(
        id: '4',
        title: 'Quality Fertiliser - NPK 2:3:2',
        description: 'Premium fertiliser for all crop types',
        type: ListingType.supplies,
        category: 'Fertiliser',
        price: 280.0,
        unit: 'per 50kg bag',
        sellerName: 'AgriSupplies Botswana',
        sellerId: 'shop1',
        location: 'Gaborone',
        quantity: '100 bags in stock',
        sellerPhone: '+267 395 1234',
        sellerEmail: 'info@agrisupplies.co.bw',
      ),
      MarketplaceListing(
        id: '5',
        title: 'Maize Seeds - Hybrid',
        description: 'High-yield drought resistant maize seeds',
        type: ListingType.supplies,
        category: 'Seeds',
        price: 450.0,
        unit: 'per 10kg bag',
        sellerName: 'AgriSupplies Botswana',
        sellerId: 'shop1',
        location: 'Gaborone',
        quantity: '50 bags available',
        sellerPhone: '+267 395 1234',
        sellerEmail: 'info@agrisupplies.co.bw',
      ),
      MarketplaceListing(
        id: '6',
        title: 'Fresh Spinach',
        description: 'Locally grown spinach',
        type: ListingType.produce,
        category: 'Vegetables',
        price: 15.0,
        unit: 'per bundle',
        sellerName: 'Tshepo Farms',
        sellerId: 'farmer4',
        location: 'Ramotswa',
        status: CropStatus.harvested,
        quantity: '100 bundles',
        sellerPhone: '+267 7667 8901',
      ),
      MarketplaceListing(
        id: '7',
        title: 'Hand Tools Set',
        description: 'Complete farming hand tools - hoes, rakes, spades',
        type: ListingType.supplies,
        category: 'Tools',
        price: 650.0,
        unit: 'per set',
        sellerName: 'FarmTools Direct',
        sellerId: 'shop2',
        location: 'Francistown',
        quantity: '20 sets',
        sellerPhone: '+267 241 2345',
        sellerEmail: 'sales@farmtools.co.bw',
      ),
      MarketplaceListing(
        id: '8',
        title: 'Sorghum',
        description: 'Traditional sorghum, great for brewing',
        type: ListingType.produce,
        category: 'Grains',
        price: 40.0,
        unit: 'per 50kg bag',
        sellerName: 'Kabo Mogotsi',
        sellerId: 'farmer5',
        location: 'Maun',
        status: CropStatus.harvested,
        quantity: '80 bags',
        sellerPhone: '+267 7778 9012',
      ),
      MarketplaceListing(
        id: '9',
        title: 'Butternut Squash',
        description: 'Almost ready for harvest',
        type: ListingType.produce,
        category: 'Vegetables',
        price: 12.0,
        unit: 'per kg',
        sellerName: 'Lorato Gardens',
        sellerId: 'farmer6',
        location: 'Mochudi',
        status: CropStatus.readyToHarvest,
        harvestDate: '2026-01-05',
        quantity: '500kg estimated',
      ),
      MarketplaceListing(
        id: '10',
        title: 'Drip Irrigation Kit',
        description: 'Water-efficient drip irrigation system',
        type: ListingType.supplies,
        category: 'Irrigation Equipment',
        price: 1200.0,
        unit: 'per kit',
        sellerName: 'WaterWise Agri',
        sellerId: 'shop3',
        location: 'Gaborone',
        quantity: '15 kits',
      ),
    ];

    state = state.copyWith(allListings: mockListings);
  }
}

class MarketplaceState {
  final List<MarketplaceListing> allListings;
  final List<MarketplaceListing> filteredListings;
  final String searchQuery;
  final String? selectedCategory;

  MarketplaceState({
    this.allListings = const [],
    List<MarketplaceListing>? filteredListings,
    this.searchQuery = '',
    this.selectedCategory,
  }) : filteredListings = filteredListings ?? allListings;

  MarketplaceState copyWith({
    List<MarketplaceListing>? allListings,
    List<MarketplaceListing>? filteredListings,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return MarketplaceState(
      allListings: allListings ?? this.allListings,
      filteredListings: filteredListings ?? this.filteredListings,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
