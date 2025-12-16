class CropModel {
  final String? id;
  final String cropType;
  final String fieldName;
  final double fieldSize;
  final String fieldSizeUnit;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final double estimatedYield;
  final String yieldUnit;
  final String storageMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CropModel({
    this.id,
    required this.cropType,
    required this.fieldName,
    required this.fieldSize,
    required this.fieldSizeUnit,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.estimatedYield,
    required this.yieldUnit,
    required this.storageMethod,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'],
      cropType: json['cropType'],
      fieldName: json['fieldName'],
      fieldSize: (json['fieldSize'] as num).toDouble(),
      fieldSizeUnit: json['fieldSizeUnit'],
      plantingDate: DateTime.parse(json['plantingDate']),
      expectedHarvestDate: DateTime.parse(json['expectedHarvestDate']),
      estimatedYield: (json['estimatedYield'] as num).toDouble(),
      yieldUnit: json['yieldUnit'],
      storageMethod: json['storageMethod'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  CropModel copyWith({
    String? id,
    String? cropType,
    String? fieldName,
    double? fieldSize,
    String? fieldSizeUnit,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    double? estimatedYield,
    String? yieldUnit,
    String? storageMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CropModel(
      id: id ?? this.id,
      cropType: cropType ?? this.cropType,
      fieldName: fieldName ?? this.fieldName,
      fieldSize: fieldSize ?? this.fieldSize,
      fieldSizeUnit: fieldSizeUnit ?? this.fieldSizeUnit,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      estimatedYield: estimatedYield ?? this.estimatedYield,
      yieldUnit: yieldUnit ?? this.yieldUnit,
      storageMethod: storageMethod ?? this.storageMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropType': cropType,
      'fieldName': fieldName,
      'fieldSize': fieldSize,
      'fieldSizeUnit': fieldSizeUnit,
      'plantingDate': plantingDate.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
      'estimatedYield': estimatedYield,
      'yieldUnit': yieldUnit,
      'storageMethod': storageMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
