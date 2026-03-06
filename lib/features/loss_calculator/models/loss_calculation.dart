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
}

class LossCalculation {
  final String cropType;
  final double harvestAmount;
  final String unit;
  final double marketPricePerUnit;
  final String storageMethod;
  final List<LossStage> stages;

  const LossCalculation({
    required this.cropType,
    required this.harvestAmount,
    required this.unit,
    required this.marketPricePerUnit,
    required this.storageMethod,
    required this.stages,
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
}
