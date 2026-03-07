import 'package:agricola/core/utils/json_extensions.dart';

class AnalyticsModel {
  final String period;
  final DateTime generatedAt;
  final CropAnalytics crops;
  final HarvestAnalytics harvests;
  final InventoryAnalytics inventory;
  final MarketplaceAnalytics marketplace;
  final OrderAnalytics orders;
  final PurchaseAnalytics purchases;

  const AnalyticsModel({
    required this.period,
    required this.generatedAt,
    required this.crops,
    required this.harvests,
    required this.inventory,
    required this.marketplace,
    required this.orders,
    required this.purchases,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      period: json.optionalString('period') ?? 'month',
      generatedAt: DateTime.tryParse(json.optionalString('generatedAt') ?? '') ??
          DateTime.now(),
      crops: CropAnalytics.fromJson(
          json['crops'] as Map<String, dynamic>? ?? {}),
      harvests: HarvestAnalytics.fromJson(
          json['harvests'] as Map<String, dynamic>? ?? {}),
      inventory: InventoryAnalytics.fromJson(
          json['inventory'] as Map<String, dynamic>? ?? {}),
      marketplace: MarketplaceAnalytics.fromJson(
          json['marketplace'] as Map<String, dynamic>? ?? {}),
      orders: OrderAnalytics.fromJson(
          json['orders'] as Map<String, dynamic>? ?? {}),
      purchases: PurchaseAnalytics.fromJson(
          json['purchases'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class CropAnalytics {
  final int total;
  final int active;
  final int harvested;
  final int upcomingHarvests;
  final double totalFieldSize;
  final double totalEstimatedYield;

  const CropAnalytics({
    this.total = 0,
    this.active = 0,
    this.harvested = 0,
    this.upcomingHarvests = 0,
    this.totalFieldSize = 0.0,
    this.totalEstimatedYield = 0.0,
  });

  factory CropAnalytics.fromJson(Map<String, dynamic> json) {
    return CropAnalytics(
      total: json.optionalInt('total') ?? 0,
      active: json.optionalInt('active') ?? 0,
      harvested: json.optionalInt('harvested') ?? 0,
      upcomingHarvests: json.optionalInt('upcomingHarvests') ?? 0,
      totalFieldSize: json.optionalDouble('totalFieldSize') ?? 0.0,
      totalEstimatedYield: json.optionalDouble('totalEstimatedYield') ?? 0.0,
    );
  }
}

class HarvestAnalytics {
  final int total;
  final double totalYield;
  final double totalLoss;

  const HarvestAnalytics({
    this.total = 0,
    this.totalYield = 0.0,
    this.totalLoss = 0.0,
  });

  factory HarvestAnalytics.fromJson(Map<String, dynamic> json) {
    return HarvestAnalytics(
      total: json.optionalInt('total') ?? 0,
      totalYield: json.optionalDouble('totalYield') ?? 0.0,
      totalLoss: json.optionalDouble('totalLoss') ?? 0.0,
    );
  }
}

class InventoryAnalytics {
  final int total;
  final int criticalItems;

  const InventoryAnalytics({this.total = 0, this.criticalItems = 0});

  factory InventoryAnalytics.fromJson(Map<String, dynamic> json) {
    return InventoryAnalytics(
      total: json.optionalInt('total') ?? 0,
      criticalItems: json.optionalInt('criticalItems') ?? 0,
    );
  }
}

class MarketplaceAnalytics {
  final int activeListings;

  const MarketplaceAnalytics({this.activeListings = 0});

  factory MarketplaceAnalytics.fromJson(Map<String, dynamic> json) {
    return MarketplaceAnalytics(
      activeListings: json.optionalInt('activeListings') ?? 0,
    );
  }
}

class OrderAnalytics {
  final int active;
  final double totalRevenue;
  final double periodRevenue;

  const OrderAnalytics({
    this.active = 0,
    this.totalRevenue = 0.0,
    this.periodRevenue = 0.0,
  });

  factory OrderAnalytics.fromJson(Map<String, dynamic> json) {
    return OrderAnalytics(
      active: json.optionalInt('active') ?? 0,
      totalRevenue: json.optionalDouble('totalRevenue') ?? 0.0,
      periodRevenue: json.optionalDouble('periodRevenue') ?? 0.0,
    );
  }
}

class PurchaseAnalytics {
  final int total;
  final double totalValue;
  final double periodValue;
  final int uniqueSuppliers;

  const PurchaseAnalytics({
    this.total = 0,
    this.totalValue = 0.0,
    this.periodValue = 0.0,
    this.uniqueSuppliers = 0,
  });

  factory PurchaseAnalytics.fromJson(Map<String, dynamic> json) {
    return PurchaseAnalytics(
      total: json.optionalInt('total') ?? 0,
      totalValue: json.optionalDouble('totalValue') ?? 0.0,
      periodValue: json.optionalDouble('periodValue') ?? 0.0,
      uniqueSuppliers: json.optionalInt('uniqueSuppliers') ?? 0,
    );
  }
}
