enum CropStatus { planted, growing, readyToHarvest, harvested }

enum ListingType { produce, supplies }

class MarketplaceListing {
  final String id;
  final String title;
  final String description;
  final ListingType type;
  final String category;
  final double? price;
  final String? unit;
  final String sellerName;
  final String sellerId;
  final String location;
  final CropStatus? status;
  final String? harvestDate;
  final String? quantity;
  final String? imagePath;
  final String? sellerPhone;
  final String? sellerEmail;
  final List<String>? additionalImages;
  final DateTime createdAt;

  MarketplaceListing({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.price,
    this.unit,
    required this.sellerName,
    required this.sellerId,
    required this.location,
    this.status,
    this.harvestDate,
    this.quantity,
    this.imagePath,
    this.sellerPhone,
    this.sellerEmail,
    this.additionalImages,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAvailableNow {
    return status == CropStatus.harvested ||
        status == CropStatus.readyToHarvest;
  }

  bool get isProduce => type == ListingType.produce;
  bool get isSupplies => type == ListingType.supplies;
}
