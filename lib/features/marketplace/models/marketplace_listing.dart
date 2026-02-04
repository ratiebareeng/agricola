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

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String,
      description: json['description'] as String,
      type: ListingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ListingType.produce,
      ),
      category: json['category'] as String,
      price: (json['price'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      sellerName: json['sellerName'] as String,
      sellerId: json['sellerId'] as String,
      location: json['location'] as String,
      status: json['status'] != null
          ? CropStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => CropStatus.harvested,
            )
          : null,
      harvestDate: json['harvestDate'] as String?,
      quantity: json['quantity'] as String?,
      imagePath: json['imagePath'] as String?,
      sellerPhone: json['sellerPhone'] as String?,
      sellerEmail: json['sellerEmail'] as String?,
      additionalImages: (json['additionalImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category,
      'price': price,
      'unit': unit,
      'sellerName': sellerName,
      'sellerId': sellerId,
      'location': location,
      'status': status?.name,
      'harvestDate': harvestDate,
      'quantity': quantity,
      'imagePath': imagePath,
      'sellerPhone': sellerPhone,
      'sellerEmail': sellerEmail,
      'additionalImages': additionalImages,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MarketplaceListing copyWith({
    String? id,
    String? title,
    String? description,
    ListingType? type,
    String? category,
    double? price,
    String? unit,
    String? sellerName,
    String? sellerId,
    String? location,
    CropStatus? status,
    String? harvestDate,
    String? quantity,
    String? imagePath,
    String? sellerPhone,
    String? sellerEmail,
    List<String>? additionalImages,
    DateTime? createdAt,
  }) {
    return MarketplaceListing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      sellerName: sellerName ?? this.sellerName,
      sellerId: sellerId ?? this.sellerId,
      location: location ?? this.location,
      status: status ?? this.status,
      harvestDate: harvestDate ?? this.harvestDate,
      quantity: quantity ?? this.quantity,
      imagePath: imagePath ?? this.imagePath,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      additionalImages: additionalImages ?? this.additionalImages,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAvailableNow {
    return status == CropStatus.harvested ||
        status == CropStatus.readyToHarvest;
  }

  bool get isProduce => type == ListingType.produce;
  bool get isSupplies => type == ListingType.supplies;
}
