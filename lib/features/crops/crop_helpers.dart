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

/// Map crop types to representative images. Falls back to maize.
String imageUrlForCrop(String cropType) {
  const images = {
    'maize':
        'https://images.unsplash.com/photo-1551754655-cd27e38d2076?q=80&w=2070&auto=format&fit=crop',
    'sorghum':
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?q=80&w=2070&auto=format&fit=crop',
    'beans':
        'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=2069&auto=format&fit=crop',
    'wheat':
        'https://images.unsplash.com/photo-1599091b9609544e4d5c61a878044f0076438309db88aa09cdc10da8897553?q=80&w=1974&auto=format&fit=crop',
    'tomatoes':
        'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=1974&auto=format&fit=crop',
    'groundnuts':
        'https://images.unsplash.com/photo-1604374894610-66a930d04661?q=80&w=1974&auto=format&fit=crop',
  };
  return images[cropType.toLowerCase()] ?? images['maize']!;
}
