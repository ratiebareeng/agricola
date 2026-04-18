import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:agricola/features/crops/models/crop_model.dart';

/// Derive a growth-stage label from planting / harvest dates.
String cropStage(CropModel crop) {
  final progress = cropProgress(crop);
  if (progress >= 0.66) return 'Harvest Ready';
  if (progress >= 0.33) return 'Flowering';
  return 'Vegetative';
}

/// Progress 0–1 based on how far through the growing period we are.
double cropProgress(CropModel crop) {
  final totalDays =
      crop.expectedHarvestDate.difference(crop.plantingDate).inDays;
  if (totalDays <= 0) return 1.0;
  final elapsed = DateTime.now().difference(crop.plantingDate).inDays;
  return (elapsed / totalDays).clamp(0.0, 1.0);
}

/// Format a date as "Mon dd, yyyy" (e.g. "Oct 15, 2023").
String formatCropDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Resolve a crop-type key (e.g. "maize_sweet_corn") to its translated
/// display name using the crop catalog. Falls back to title-casing the key.
String cropDisplayName(
  String cropType,
  List<CropCatalogEntry> catalog,
  AppLanguage lang,
) {
  final entry = catalog.where((e) => e.key == cropType).firstOrNull;
  if (entry != null) return entry.displayName(lang);
  // Fallback: convert snake_case to Title Case
  return cropType
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Look up a crop image URL from the server-provided [imageMap].
/// Returns an empty string when no image is available — consumers should
/// render an icon placeholder in that case. The previous maize fallback was
/// removed because it caused mismatched images (e.g. "Rape" showing corn).
String imageUrlForCrop(String cropType, Map<String, String> imageMap) {
  return imageMap[cropType.toLowerCase()] ?? '';
}
