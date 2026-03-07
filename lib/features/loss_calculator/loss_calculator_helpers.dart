import 'package:agricola/features/loss_calculator/models/loss_calculation.dart';

/// Botswana average post-harvest loss percentages by crop category.
/// Source: FAO post-harvest loss data for Sub-Saharan Africa.
const Map<String, double> regionalAverageLoss = {
  'cereals': 15.0,
  'vegetables': 25.0,
  'fruits': 30.0,
  'legumes': 12.0,
  'roots_tubers': 20.0,
  'default': 18.0,
};

/// Maps crop catalog categories to loss categories
String lossCategory(String cropCategory) {
  switch (cropCategory.toLowerCase()) {
    case 'cereals':
    case 'grains':
      return 'cereals';
    case 'vegetables':
      return 'vegetables';
    case 'fruits':
      return 'fruits';
    case 'legumes':
    case 'pulses':
      return 'legumes';
    case 'roots':
    case 'tubers':
    case 'roots_tubers':
      return 'roots_tubers';
    default:
      return 'default';
  }
}

double regionalAverage(String cropCategory) {
  final cat = lossCategory(cropCategory);
  return regionalAverageLoss[cat] ?? regionalAverageLoss['default']!;
}

/// Loss cause options per stage
const Map<String, List<String>> lossCausesPerStage = {
  'field': [
    'pest_damage',
    'weather_damage',
    'mechanical_damage',
    'late_harvest',
  ],
  'transport': [
    'handling_damage',
    'spillage',
    'heat_exposure',
    'poor_packaging',
  ],
  'storage': [
    'pest_damage',
    'spoilage',
    'moisture_damage',
    'rodent_damage',
  ],
  'processing': [
    'threshing_loss',
    'cleaning_loss',
    'drying_loss',
    'other_loss',
  ],
};

/// Prevention tips keyed by loss stage, returns translation keys.
/// Each tip is a translation key that must exist in language_provider.dart.
List<String> preventionTipKeys(String stage, String storageMethod) {
  switch (stage) {
    case 'field':
      return [
        'tip_field_timely_harvest',
        'tip_field_pest_management',
        'tip_field_proper_handling',
      ];
    case 'transport':
      return [
        'tip_transport_proper_containers',
        'tip_transport_minimize_distance',
        'tip_transport_avoid_heat',
      ];
    case 'storage':
      final tips = [
        'tip_storage_dry_before_storing',
        'tip_storage_use_hermetic',
        'tip_storage_check_regularly',
      ];
      if (storageMethod == 'open_air' || storageMethod == 'traditional_granary') {
        tips.insert(0, 'tip_storage_upgrade_method');
      }
      return tips;
    case 'processing':
      return [
        'tip_processing_calibrate_equipment',
        'tip_processing_proper_drying',
        'tip_processing_train_workers',
      ];
    default:
      return ['tip_general_record_losses'];
  }
}

/// Returns a severity label key based on loss percentage
String lossSeverityKey(double lossPercentage) {
  if (lossPercentage <= 5) return 'loss_severity_low';
  if (lossPercentage <= 15) return 'loss_severity_moderate';
  if (lossPercentage <= 25) return 'loss_severity_high';
  return 'loss_severity_critical';
}

/// Format currency in BWP (Botswana Pula)
String formatBWP(double amount) {
  return 'P${amount.toStringAsFixed(2)}';
}

/// Build a summary comparing user losses to regional average
LossComparisonResult compareLossToRegional(
  LossCalculation calc,
  String cropCategory,
) {
  final average = regionalAverage(cropCategory);
  final userPercent = calc.totalLossPercentage;
  final diff = userPercent - average;

  return LossComparisonResult(
    userPercentage: userPercent,
    regionalAverage: average,
    difference: diff,
    isBelowAverage: diff < 0,
  );
}

class LossComparisonResult {
  final double userPercentage;
  final double regionalAverage;
  final double difference;
  final bool isBelowAverage;

  const LossComparisonResult({
    required this.userPercentage,
    required this.regionalAverage,
    required this.difference,
    required this.isBelowAverage,
  });
}
