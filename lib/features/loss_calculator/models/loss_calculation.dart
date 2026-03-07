import 'package:agricola/core/utils/json_extensions.dart';

class LossStage {
  final String stage; // field, transport, storage, processing
  final double amount; // kg lost
  final String? cause;

  const LossStage({
    required this.stage,
    required this.amount,
    this.cause,
  });

  double percentage(double totalHarvest) {
    if (totalHarvest <= 0) return 0;
    return (amount / totalHarvest) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'amount': amount,
      if (cause != null) 'cause': cause,
    };
  }

  factory LossStage.fromJson(Map<String, dynamic> json) {
    return LossStage(
      stage: json['stage'] as String,
      amount: (json['amount'] as num).toDouble(),
      cause: json['cause'] as String?,
    );
  }
}

class LossCalculation {
  final String? id;
  final String? userId;
  final String cropType;
  final String? cropCategory;
  final double harvestAmount;
  final String unit;
  final double marketPricePerUnit;
  final String storageMethod;
  final List<LossStage> stages;
  final DateTime? calculationDate;
  final DateTime? createdAt;

  const LossCalculation({
    this.id,
    this.userId,
    required this.cropType,
    this.cropCategory,
    required this.harvestAmount,
    required this.unit,
    required this.marketPricePerUnit,
    required this.storageMethod,
    required this.stages,
    this.calculationDate,
    this.createdAt,
  });

  double get totalLoss => stages.fold(0.0, (sum, s) => sum + s.amount);

  double get totalLossPercentage {
    if (harvestAmount <= 0) return 0;
    return (totalLoss / harvestAmount) * 100;
  }

  double get monetaryLoss => totalLoss * marketPricePerUnit;

  double get remainingAmount => harvestAmount - totalLoss;

  double get remainingValue => remainingAmount * marketPricePerUnit;

  double get totalValue => harvestAmount * marketPricePerUnit;

  /// Returns the stage with the highest loss
  LossStage? get highestLossStage {
    if (stages.isEmpty) return null;
    return stages.reduce((a, b) => a.amount >= b.amount ? a : b);
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cropType': cropType,
      if (cropCategory != null) 'cropCategory': cropCategory,
      'harvestAmount': harvestAmount,
      'unit': unit,
      'marketPricePerUnit': marketPricePerUnit,
      'storageMethod': storageMethod,
      'stages': stages.map((s) => s.toJson()).toList(),
      'calculationDate':
          (calculationDate ?? DateTime.now()).toIso8601String(),
    };
  }

  factory LossCalculation.fromJson(Map<String, dynamic> json) {
    final stagesRaw = json['stages'] as List<dynamic>;
    return LossCalculation(
      id: json.optionalString('id'),
      userId: json['userId'] as String?,
      cropType: json['cropType'] as String,
      cropCategory: json['cropCategory'] as String?,
      harvestAmount: (json['harvestAmount'] as num).toDouble(),
      unit: json['unit'] as String,
      marketPricePerUnit: (json['marketPricePerUnit'] as num).toDouble(),
      storageMethod: json['storageMethod'] as String,
      stages: stagesRaw
          .map((s) => LossStage.fromJson(s as Map<String, dynamic>))
          .toList(),
      calculationDate: json['calculationDate'] != null
          ? DateTime.parse(json['calculationDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  LossCalculation copyWith({
    String? id,
    String? userId,
    String? cropType,
    String? cropCategory,
    double? harvestAmount,
    String? unit,
    double? marketPricePerUnit,
    String? storageMethod,
    List<LossStage>? stages,
    DateTime? calculationDate,
    DateTime? createdAt,
  }) {
    return LossCalculation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropType: cropType ?? this.cropType,
      cropCategory: cropCategory ?? this.cropCategory,
      harvestAmount: harvestAmount ?? this.harvestAmount,
      unit: unit ?? this.unit,
      marketPricePerUnit: marketPricePerUnit ?? this.marketPricePerUnit,
      storageMethod: storageMethod ?? this.storageMethod,
      stages: stages ?? this.stages,
      calculationDate: calculationDate ?? this.calculationDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
