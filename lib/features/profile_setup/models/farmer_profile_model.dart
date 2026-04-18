import 'package:agricola/core/utils/json_extensions.dart';
import 'package:equatable/equatable.dart';

class FarmerProfileModel extends Equatable {
  final String id;
  final String userId;
  final String village;
  final String? customVillage;
  final List<String> primaryCrops;
  final String farmSize;
  final String? photoUrl;
  final String? phoneNumber;
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
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      id: json.requiredString('id'),
      userId: (json['userId'] as String?) ?? '',
      village: (json['village'] as String?) ?? '',
      customVillage: json['customVillage'] as String?,
      primaryCrops: List<String>.from(json['primaryCrops'] ?? []),
      farmSize: (json['farmSize'] as String?) ?? '',
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
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
    phoneNumber,
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
    String? phoneNumber,
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
      phoneNumber: phoneNumber ?? this.phoneNumber,
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
      'phoneNumber': phoneNumber,
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
      'phoneNumber': phoneNumber,
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
      'phoneNumber': phoneNumber,
    };
  }
}
