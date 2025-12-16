class InventoryModel {
  final String? id;
  final String cropType;
  final double quantity;
  final String unit;
  final DateTime storageDate;
  final String storageLocation;
  final String condition;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryModel({
    this.id,
    required this.cropType,
    required this.quantity,
    required this.unit,
    required this.storageDate,
    required this.storageLocation,
    required this.condition,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      cropType: json['cropType'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      storageDate: DateTime.parse(json['storageDate']),
      storageLocation: json['storageLocation'],
      condition: json['condition'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  InventoryModel copyWith({
    String? id,
    String? cropType,
    double? quantity,
    String? unit,
    DateTime? storageDate,
    String? storageLocation,
    String? condition,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      cropType: cropType ?? this.cropType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      storageDate: storageDate ?? this.storageDate,
      storageLocation: storageLocation ?? this.storageLocation,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropType': cropType,
      'quantity': quantity,
      'unit': unit,
      'storageDate': storageDate.toIso8601String(),
      'storageLocation': storageLocation,
      'condition': condition,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
