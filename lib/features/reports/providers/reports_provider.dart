import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/crops/crop_helpers.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/home/providers/dashboard_stats_provider.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/orders/providers/orders_provider.dart';
import 'package:agricola/features/purchases/providers/purchases_provider.dart';
import 'package:agricola/features/reports/data/analytics_api_service.dart';
import 'package:agricola/features/reports/models/analytics_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Analytics API — server-side aggregated stats
// ---------------------------------------------------------------------------

final analyticsApiServiceProvider = Provider<AnalyticsApiService>((ref) {
  return AnalyticsApiService(ref.watch(httpClientProvider));
});

final analyticsProvider =
    FutureProvider.family<AnalyticsModel, String>((ref, period) async {
  // Re-fetch analytics when user changes
  ref.watch(currentUserProvider);
  final service = ref.watch(analyticsApiServiceProvider);
  return service.getAnalytics(period: period);
});

// ---------------------------------------------------------------------------
// Farmer reports — computed from crops + inventory
// ---------------------------------------------------------------------------

class FarmerReportStats {
  final int totalCrops;
  final int activeCrops;
  final int harvestedCrops;
  final int upcomingHarvests;
  final double totalFieldSize;
  final double totalEstimatedYield;
  final int inventoryItems;
  final int criticalItems;
  final int marketplaceListings;
  final bool isLoading;

  const FarmerReportStats({
    this.totalCrops = 0,
    this.activeCrops = 0,
    this.harvestedCrops = 0,
    this.upcomingHarvests = 0,
    this.totalFieldSize = 0.0,
    this.totalEstimatedYield = 0.0,
    this.inventoryItems = 0,
    this.criticalItems = 0,
    this.marketplaceListings = 0,
    this.isLoading = false,
  });
}

final farmerReportStatsProvider = Provider<FarmerReportStats>((ref) {
  final cropsAsync = ref.watch(cropNotifierProvider);
  final inventoryAsync = ref.watch(inventoryNotifierProvider);
  final listingsAsync = ref.watch(myListingsNotifierProvider);

  if (cropsAsync.isLoading || inventoryAsync.isLoading || listingsAsync.isLoading) {
    return const FarmerReportStats(isLoading: true);
  }

  final crops = cropsAsync.valueOrNull ?? [];
  final inventory = inventoryAsync.valueOrNull ?? [];
  final listings = listingsAsync.valueOrNull ?? [];
  final now = DateTime.now();

  final activeCrops = crops.where((c) => c.expectedHarvestDate.isAfter(now)).toList();
  final harvestedCrops = crops.where((c) => c.expectedHarvestDate.isBefore(now)).toList();
  final upcomingHarvests = crops
      .where((c) =>
          c.expectedHarvestDate.isAfter(now) &&
          c.expectedHarvestDate.isBefore(now.add(const Duration(days: 30))))
      .length;

  final totalFieldSize = crops.fold(0.0, (sum, c) => sum + c.fieldSize);
  final totalEstimatedYield = crops.fold(0.0, (sum, c) => sum + c.estimatedYield);

  final criticalItems = inventory
      .where((i) => i.condition == 'critical' || i.condition == 'needs_attention')
      .length;

  return FarmerReportStats(
    totalCrops: crops.length,
    activeCrops: activeCrops.length,
    harvestedCrops: harvestedCrops.length,
    upcomingHarvests: upcomingHarvests,
    totalFieldSize: totalFieldSize,
    totalEstimatedYield: totalEstimatedYield,
    inventoryItems: inventory.length,
    criticalItems: criticalItems,
    marketplaceListings: listings.length,
  );
});

// ---------------------------------------------------------------------------
// Merchant reports — computed from inventory + purchases + listings + orders
// ---------------------------------------------------------------------------

class MerchantReportStats {
  final int totalProducts;
  final int totalPurchases;
  final double totalPurchaseValue;
  final double monthlyPurchaseValue;
  final int totalSuppliers;
  final int inventoryItems;
  final int lowStockItems;
  final int activeOrders;
  final double monthlyRevenue;
  final double totalRevenue;
  final int marketplaceListings;
  final bool isLoading;

  const MerchantReportStats({
    this.totalProducts = 0,
    this.totalPurchases = 0,
    this.totalPurchaseValue = 0.0,
    this.monthlyPurchaseValue = 0.0,
    this.totalSuppliers = 0,
    this.inventoryItems = 0,
    this.lowStockItems = 0,
    this.activeOrders = 0,
    this.monthlyRevenue = 0.0,
    this.totalRevenue = 0.0,
    this.marketplaceListings = 0,
    this.isLoading = false,
  });
}

final merchantReportStatsProvider = Provider<MerchantReportStats>((ref) {
  final listingsAsync = ref.watch(myListingsNotifierProvider);
  final inventoryAsync = ref.watch(inventoryNotifierProvider);
  final purchasesAsync = ref.watch(purchasesNotifierProvider);
  final ordersAsync = ref.watch(ordersNotifierProvider);

  if (listingsAsync.isLoading ||
      inventoryAsync.isLoading ||
      purchasesAsync.isLoading ||
      ordersAsync.isLoading) {
    return const MerchantReportStats(isLoading: true);
  }

  final listings = listingsAsync.valueOrNull ?? [];
  final inventory = inventoryAsync.valueOrNull ?? [];
  final purchases = purchasesAsync.valueOrNull ?? [];
  final orders = ordersAsync.valueOrNull ?? [];
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  final lowStockConditions = {'needs_attention', 'critical'};
  final activeStatuses = {'pending', 'confirmed', 'shipped'};

  final totalPurchaseValue = purchases.fold(0.0, (sum, p) => sum + p.totalAmount);
  final monthlyPurchaseValue = purchases
      .where((p) => p.purchaseDate.isAfter(startOfMonth))
      .fold(0.0, (sum, p) => sum + p.totalAmount);

  final totalRevenue = orders
      .where((o) => o.status == 'delivered')
      .fold(0.0, (sum, o) => sum + o.totalAmount);
  final monthlyRevenue = orders
      .where((o) => o.status == 'delivered' && o.createdAt.isAfter(startOfMonth))
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  return MerchantReportStats(
    totalProducts: listings.length,
    totalPurchases: purchases.length,
    totalPurchaseValue: totalPurchaseValue,
    monthlyPurchaseValue: monthlyPurchaseValue,
    totalSuppliers: purchases.map((p) => p.sellerName).toSet().length,
    inventoryItems: inventory.length,
    lowStockItems: inventory.where((i) => lowStockConditions.contains(i.condition)).length,
    activeOrders: orders.where((o) => activeStatuses.contains(o.status)).length,
    monthlyRevenue: monthlyRevenue,
    totalRevenue: totalRevenue,
    marketplaceListings: listings.length,
  );
});

// ---------------------------------------------------------------------------
// Recent activity timeline — combines recent crops, inventory, and purchases
// ---------------------------------------------------------------------------

class ActivityItem {
  final String title;
  final String subtitle;
  final DateTime date;
  final ActivityType type;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
  });
}

enum ActivityType { crop, inventory, purchase, listing }

final recentActivityProvider = Provider<List<ActivityItem>>((ref) {
  final lang = ref.watch(languageProvider);
  final catalog = ref.watch(cropCatalogProvider).valueOrNull ?? [];
  final cropsAsync = ref.watch(cropNotifierProvider);
  final inventoryAsync = ref.watch(inventoryNotifierProvider);
  final purchasesAsync = ref.watch(purchasesNotifierProvider);
  final listingsAsync = ref.watch(myListingsNotifierProvider);

  final activities = <ActivityItem>[];

  for (final crop in cropsAsync.valueOrNull ?? <CropModel>[]) {
    activities.add(ActivityItem(
      title: 'Planted ${cropDisplayName(crop.cropType, catalog, lang)}',
      subtitle: crop.fieldName,
      date: crop.createdAt,
      type: ActivityType.crop,
    ));
  }

  for (final item in inventoryAsync.valueOrNull ?? []) {
    activities.add(ActivityItem(
      title: 'Stored ${cropDisplayName(item.cropType, catalog, lang)}',
      subtitle: '${item.quantity} ${item.unit} at ${item.storageLocation}',
      date: item.createdAt,
      type: ActivityType.inventory,
    ));
  }

  for (final purchase in purchasesAsync.valueOrNull ?? []) {
    activities.add(ActivityItem(
      title: 'Purchased ${purchase.cropType}',
      subtitle: 'P ${purchase.totalAmount.toStringAsFixed(2)} from ${purchase.sellerName}',
      date: purchase.purchaseDate,
      type: ActivityType.purchase,
    ));
  }

  for (final listing in listingsAsync.valueOrNull ?? []) {
    activities.add(ActivityItem(
      title: 'Listed ${listing.title}',
      subtitle: listing.price != null ? 'P ${listing.price!.toStringAsFixed(2)}' : 'No price set',
      date: listing.createdAt,
      type: ActivityType.listing,
    ));
  }

  activities.sort((a, b) => b.date.compareTo(a.date));
  return activities.take(20).toList();
});
