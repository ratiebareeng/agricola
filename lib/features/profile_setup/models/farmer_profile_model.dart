class FarmerProfileModel {
  final String id;
  final String userId;
  final String village;
  final String? customVillage;
  final List<String> primaryCrops;
  final String farmSize;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  FarmerProfileModel({
    required this.id,
    required this.userId,
    required this.village,
    this.customVillage,
    required this.primaryCrops,
    required this.farmSize,
    this.photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      id: json['id'],
      userId: json['userId'],
      village: json['village'],
      customVillage: json['customVillage'],
      primaryCrops: List<String>.from(json['primaryCrops'] ?? []),
      farmSize: json['farmSize'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get displayLocation {
    if (village == 'Other' && customVillage != null) {
      return customVillage!;
    }
    return village;
  }

  FarmerProfileModel copyWith({
    String? id,
    String? userId,
    String? village,
    String? customVillage,
    List<String>? primaryCrops,
    String? farmSize,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmerProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      village: village ?? this.village,
      customVillage: customVillage ?? this.customVillage,
      primaryCrops: primaryCrops ?? this.primaryCrops,
      farmSize: farmSize ?? this.farmSize,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'village': village,
      'customVillage': customVillage,
      'primaryCrops': primaryCrops,
      'farmSize': farmSize,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
