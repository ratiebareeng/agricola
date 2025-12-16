class HarvestModel {
  final String? id;
  final String cropId;
  final DateTime harvestDate;
  final double actualYield;
  final String yieldUnit;
  final String quality;
  final double? lossAmount;
  final String? lossReason;
  final String storageLocation;
  final String? notes;
  final DateTime createdAt;

  HarvestModel({
    this.id,
    required this.cropId,
    required this.harvestDate,
    required this.actualYield,
    required this.yieldUnit,
    required this.quality,
    this.lossAmount,
    this.lossReason,
    required this.storageLocation,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HarvestModel.fromJson(Map<String, dynamic> json) {
    return HarvestModel(
      id: json['id'],
      cropId: json['cropId'],
      harvestDate: DateTime.parse(json['harvestDate']),
      actualYield: (json['actualYield'] as num).toDouble(),
      yieldUnit: json['yieldUnit'],
      quality: json['quality'],
      lossAmount: json['lossAmount'] != null
          ? (json['lossAmount'] as num).toDouble()
          : null,
      lossReason: json['lossReason'],
      storageLocation: json['storageLocation'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropId': cropId,
      'harvestDate': harvestDate.toIso8601String(),
      'actualYield': actualYield,
      'yieldUnit': yieldUnit,
      'quality': quality,
      'lossAmount': lossAmount,
      'lossReason': lossReason,
      'storageLocation': storageLocation,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
