import 'package:agricola/core/utils/json_extensions.dart';

class PurchaseModel {
  final String? id;
  final String userId;
  final String sellerName;
  final String cropType;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final DateTime purchaseDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseModel({
    this.id,
    required this.userId,
    required this.sellerName,
    required this.cropType,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.purchaseDate,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json.optionalString('id'),
      userId: json['userId'] as String,
      sellerName: json['sellerName'] as String,
      cropType: json['cropType'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'sellerName': sellerName,
      'cropType': cropType,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalAmount,
      'purchaseDate': purchaseDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PurchaseModel copyWith({
    String? id,
    String? userId,
    String? sellerName,
    String? cropType,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    double? totalAmount,
    DateTime? purchaseDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerName: sellerName ?? this.sellerName,
      cropType: cropType ?? this.cropType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalAmount: totalAmount ?? this.totalAmount,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
