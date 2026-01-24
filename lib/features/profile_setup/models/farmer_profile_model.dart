import 'package:equatable/equatable.dart';

class FarmerProfileModel extends Equatable {
  final String id;
  final String userId;
  final String village;
  final String? customVillage;
  final List<String> primaryCrops;
  final String farmSize;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmerProfileModel({
    required this.id,
    required this.userId,
    required this.village,
    this.customVillage,
    required this.primaryCrops,
    required this.farmSize,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      id: json['id'].toString(), // Convert to string (server returns int)
      userId: json['userId'] as String,
      village: json['village'] as String,
      customVillage: json['customVillage'] as String?,
      primaryCrops: List<String>.from(json['primaryCrops'] ?? []),
      farmSize: json['farmSize'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get displayLocation {
    if (village == 'Other' && customVillage != null) {
      return customVillage!;
    }
    return village;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    village,
    customVillage,
    primaryCrops,
    farmSize,
    photoUrl,
    createdAt,
    updatedAt,
  ];

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

  Map<String, dynamic> toCreateRequest() {
    return {
      'userId': userId,
      'village': village,
      'customVillage': customVillage,
      'primaryCrops': primaryCrops,
      'farmSize': farmSize,
      'photoUrl': photoUrl,
    };
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

  Map<String, dynamic> toUpdateRequest() {
    return {
      'village': village,
      'customVillage': customVillage,
      'primaryCrops': primaryCrops,
      'farmSize': farmSize,
      'photoUrl': photoUrl,
    };
  }
}
