/// An item available for purchase right now on the marketplace.
class AvailableNowItem {
  final String id;
  final String title;
  final String cropType;
  final double? price;
  final String? unit;
  final String? quantity;
  final String sellerName;
  final String location;
  final String? imagePath;
  final DateTime createdAt;

  const AvailableNowItem({
    required this.id,
    required this.title,
    required this.cropType,
    this.price,
    this.unit,
    this.quantity,
    required this.sellerName,
    required this.location,
    this.imagePath,
    required this.createdAt,
  });

  factory AvailableNowItem.fromJson(Map<String, dynamic> json) {
    return AvailableNowItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      cropType: json['cropType'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      unit: json['unit'] as String?,
      quantity: json['quantity'] as String?,
      sellerName: json['sellerName'] ?? '',
      location: json['location'] ?? '',
      imagePath: json['imagePath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// An upcoming crop harvest from a farmer.
class UpcomingHarvestItem {
  final String id;
  final String cropType;
  final double? estimatedYield;
  final String? yieldUnit;
  final DateTime? expectedHarvestDate;
  final int daysUntilHarvest;
  final String? location;
  final String availabilityWindow;

  const UpcomingHarvestItem({
    required this.id,
    required this.cropType,
    this.estimatedYield,
    this.yieldUnit,
    this.expectedHarvestDate,
    required this.daysUntilHarvest,
    this.location,
    required this.availabilityWindow,
  });

  factory UpcomingHarvestItem.fromJson(Map<String, dynamic> json) {
    return UpcomingHarvestItem(
      id: json['id']?.toString() ?? '',
      cropType: json['cropType'] ?? '',
      estimatedYield: json['estimatedYield'] != null
          ? (json['estimatedYield'] as num).toDouble()
          : null,
      yieldUnit: json['yieldUnit'] as String?,
      expectedHarvestDate: json['expectedHarvestDate'] != null
          ? DateTime.tryParse(json['expectedHarvestDate'].toString())
          : null,
      daysUntilHarvest: (json['daysUntilHarvest'] as num?)?.toInt() ?? 0,
      location: json['location'] as String?,
      availabilityWindow: json['availabilityWindow'] ?? 'in_6_weeks',
    );
  }
}

class CropAvailabilityData {
  final List<AvailableNowItem> availableNow;
  final List<UpcomingHarvestItem> upcoming;

  const CropAvailabilityData({
    required this.availableNow,
    required this.upcoming,
  });

  factory CropAvailabilityData.empty() =>
      const CropAvailabilityData(availableNow: [], upcoming: []);

  List<UpcomingHarvestItem> get in2Weeks =>
      upcoming.where((h) => h.availabilityWindow == 'in_2_weeks').toList();

  List<UpcomingHarvestItem> get in4Weeks =>
      upcoming.where((h) => h.availabilityWindow == 'in_4_weeks').toList();

  List<UpcomingHarvestItem> get in6Weeks =>
      upcoming.where((h) => h.availabilityWindow == 'in_6_weeks').toList();
}
