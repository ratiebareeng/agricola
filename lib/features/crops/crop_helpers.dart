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

/// Fallback image URL when no crop-specific image is available.
const _fallbackImageUrl =
    'https://images.unsplash.com/photo-1551754655-cd27e38d2076?q=80&w=2070&auto=format&fit=crop';

/// Look up a crop image from the server-provided [imageMap].
/// Falls back to a generic maize image if the crop has no entry.
String imageUrlForCrop(String cropType, Map<String, String> imageMap) {
  return imageMap[cropType.toLowerCase()] ?? _fallbackImageUrl;
}
