import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:equatable/equatable.dart';

class MerchantProfileModel extends Equatable {
  final String id;
  final String userId;
  final MerchantType merchantType;
  final String businessName;
  final String location;
  final String? customLocation;
  final List<String> productsOffered;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MerchantProfileModel({
    required this.id,
    required this.userId,
    required this.merchantType,
    required this.businessName,
    required this.location,
    this.customLocation,
    required this.productsOffered,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantProfileModel.fromJson(Map<String, dynamic> json) {
    return MerchantProfileModel(
      id: json['id']?.toString() ?? '', // Convert to string (server returns int)
      userId: (json['userId'] as String?) ?? '',
      merchantType: MerchantType.fromString((json['merchantType'] as String?) ?? 'market_vendor'),
      businessName: (json['businessName'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      customLocation: json['customLocation'] as String?,
      productsOffered: List<String>.from(json['productsOffered'] ?? []),
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  String get displayLocation {
    if (location == 'Other' && customLocation != null) {
      return customLocation!;
    }
    return location;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    merchantType,
    businessName,
    location,
    customLocation,
    productsOffered,
    photoUrl,
    createdAt,
    updatedAt,
  ];

  MerchantProfileModel copyWith({
    String? id,
    String? userId,
    MerchantType? merchantType,
    String? businessName,
    String? location,
    String? customLocation,
    List<String>? productsOffered,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantType: merchantType ?? this.merchantType,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      customLocation: customLocation ?? this.customLocation,
      productsOffered: productsOffered ?? this.productsOffered,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toCreateRequest() {
    return {
      'userId': userId,
      'merchantType': merchantType.name,
      'businessName': businessName,
      'location': location,
      'customLocation': customLocation,
      'productsOffered': productsOffered,
      'photoUrl': photoUrl,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'merchantType': merchantType.name,
      'businessName': businessName,
      'location': location,
      'customLocation': customLocation,
      'productsOffered': productsOffered,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateRequest() {
    return {
      'merchantType': merchantType.name,
      'businessName': businessName,
      'location': location,
      'customLocation': customLocation,
      'productsOffered': productsOffered,
      'photoUrl': photoUrl,
    };
  }
}
