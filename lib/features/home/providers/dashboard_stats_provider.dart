import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/marketplace/data/marketplace_api_service.dart';
import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart'
    show marketplaceApiServiceProvider;
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/orders/providers/orders_provider.dart';
import 'package:agricola/features/purchases/providers/purchases_provider.dart';
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

/// Stats model for merchant dashboards (AgriShop and non-AgriShop)
class MerchantDashboardStats {
  final int totalProducts;
  final double monthlyRevenue;
  final int activeOrders;
  final int lowStockItems;
  final List<OrderModel> recentOrders;
  final double monthlyPurchases;
  final int totalSuppliers;
  final bool isLoading;
  final String? error;

  const MerchantDashboardStats({
    this.totalProducts = 0,
    this.monthlyRevenue = 0.0,
    this.activeOrders = 0,
    this.lowStockItems = 0,
    this.recentOrders = const [],
    this.monthlyPurchases = 0.0,
    this.totalSuppliers = 0,
    this.isLoading = false,
    this.error,
  });
}

/// Provider that computes dashboard stats from orders, inventory, listings, and purchases
final merchantDashboardStatsProvider =
    Provider<MerchantDashboardStats>((ref) {
  final listingsAsync = ref.watch(myListingsNotifierProvider);
  final ordersAsync = ref.watch(ordersNotifierProvider);
  final inventoryAsync = ref.watch(inventoryNotifierProvider);
  final purchasesAsync = ref.watch(purchasesNotifierProvider);

  if (listingsAsync.isLoading ||
      ordersAsync.isLoading ||
      inventoryAsync.isLoading ||
      purchasesAsync.isLoading) {
    return const MerchantDashboardStats(isLoading: true);
  }

  final errors = <String>[];
  if (listingsAsync.hasError) errors.add('listings');
  if (ordersAsync.hasError) errors.add('orders');
  if (inventoryAsync.hasError) errors.add('inventory');
  if (purchasesAsync.hasError) errors.add('purchases');

  if (errors.isNotEmpty) {
    return MerchantDashboardStats(
      error: 'Failed to load: ${errors.join(", ")}',
    );
  }

  final listings = listingsAsync.value ?? [];
  final orders = ordersAsync.value ?? [];
  final inventory = inventoryAsync.value ?? [];
  final purchases = purchasesAsync.value ?? [];

  // Total products: marketplace listings count
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

  // Recent orders: last 5 sorted by date
  final recentOrders = List<OrderModel>.from(orders)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Monthly purchases: sum of purchases in current month
  final monthlyPurchases = purchases
      .where((p) => p.purchaseDate.isAfter(startOfMonth))
      .fold(0.0, (sum, p) => sum + p.totalAmount);

  // Total suppliers: distinct seller names
  final totalSuppliers =
      purchases.map((p) => p.sellerName).toSet().length;

  return MerchantDashboardStats(
    totalProducts: totalProducts,
    monthlyRevenue: monthlyRevenue,
    activeOrders: activeOrders,
    lowStockItems: lowStockItems,
    recentOrders: recentOrders.take(5).toList(),
    monthlyPurchases: monthlyPurchases,
    totalSuppliers: totalSuppliers,
  );
});
