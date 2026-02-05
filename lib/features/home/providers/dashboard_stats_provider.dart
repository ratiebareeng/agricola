import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/marketplace/data/marketplace_api_service.dart';
import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/orders/providers/orders_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for fetching the current user's own marketplace listings
final myListingsNotifierProvider = StateNotifierProvider<MyListingsNotifier,
    AsyncValue<List<MarketplaceListing>>>((ref) {
  final service = ref.watch(marketplaceApiServiceProvider);
  final user = ref.watch(currentUserProvider);
  return MyListingsNotifier(service, user?.uid);
});

class MyListingsNotifier
    extends StateNotifier<AsyncValue<List<MarketplaceListing>>> {
  final MarketplaceApiService _service;
  final String? _userId;

  MyListingsNotifier(this._service, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadMyListings();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadMyListings() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final filter = MarketplaceFilter(sellerId: _userId);
      final listings = await _service.getListings(filter: filter);
      state = AsyncValue.data(listings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Stats model for AgriShop dashboard
class MerchantDashboardStats {
  final int totalProducts;
  final double monthlyRevenue;
  final int activeOrders;
  final int lowStockItems;
  final List<OrderModel> recentOrders;
  final bool isLoading;
  final String? error;

  const MerchantDashboardStats({
    this.totalProducts = 0,
    this.monthlyRevenue = 0.0,
    this.activeOrders = 0,
    this.lowStockItems = 0,
    this.recentOrders = const [],
    this.isLoading = false,
    this.error,
  });

  MerchantDashboardStats copyWith({
    int? totalProducts,
    double? monthlyRevenue,
    int? activeOrders,
    int? lowStockItems,
    List<OrderModel>? recentOrders,
    bool? isLoading,
    String? error,
  }) {
    return MerchantDashboardStats(
      totalProducts: totalProducts ?? this.totalProducts,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      activeOrders: activeOrders ?? this.activeOrders,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      recentOrders: recentOrders ?? this.recentOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider that computes dashboard stats from orders, inventory, and listings
final merchantDashboardStatsProvider =
    Provider<MerchantDashboardStats>((ref) {
  final listingsAsync = ref.watch(myListingsNotifierProvider);
  final ordersAsync = ref.watch(ordersNotifierProvider);
  final inventoryAsync = ref.watch(inventoryNotifierProvider);

  // Check if any are loading
  if (listingsAsync.isLoading ||
      ordersAsync.isLoading ||
      inventoryAsync.isLoading) {
    return const MerchantDashboardStats(isLoading: true);
  }

  // Check for errors
  final errors = <String>[];
  if (listingsAsync.hasError) errors.add('listings');
  if (ordersAsync.hasError) errors.add('orders');
  if (inventoryAsync.hasError) errors.add('inventory');

  if (errors.isNotEmpty) {
    return MerchantDashboardStats(
      error: 'Failed to load: ${errors.join(", ")}',
    );
  }

  // Get the data
  final listings = listingsAsync.value ?? [];
  final orders = ordersAsync.value ?? [];
  final inventory = inventoryAsync.value ?? [];

  // Calculate stats
  final totalProducts = listings.length;

  // Active orders: pending, confirmed, or shipped
  final activeStatuses = {'pending', 'confirmed', 'shipped'};
  final activeOrders =
      orders.where((o) => activeStatuses.contains(o.status)).length;

  // Monthly revenue: sum of delivered orders in current month
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final monthlyRevenue = orders
      .where((o) =>
          o.status == 'delivered' && o.createdAt.isAfter(startOfMonth))
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  // Low stock: inventory items with needs_attention or critical condition
  final lowStockConditions = {'needs_attention', 'critical'};
  final lowStockItems =
      inventory.where((i) => lowStockConditions.contains(i.condition)).length;

  // Recent orders: last 5 orders sorted by date
  final recentOrders = List<OrderModel>.from(orders)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final limitedRecentOrders =
      recentOrders.take(5).toList();

  return MerchantDashboardStats(
    totalProducts: totalProducts,
    monthlyRevenue: monthlyRevenue,
    activeOrders: activeOrders,
    lowStockItems: lowStockItems,
    recentOrders: limitedRecentOrders,
  );
});
