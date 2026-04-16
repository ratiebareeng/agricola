import 'package:agricola/features/crops/crop_helpers.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('imageUrlForCrop', () {
    final imageMap = {
      'maize': 'https://example.com/crops/maize.jpg',
      'sorghum': 'https://example.com/crops/sorghum.jpg',
      'beans': 'https://example.com/crops/beans.jpg',
    };

    test('returns catalog URL for known crop type', () {
      final url = imageUrlForCrop('maize', imageMap);
      expect(url, 'https://example.com/crops/maize.jpg');
    });

    test('is case-insensitive', () {
      final url = imageUrlForCrop('Maize', imageMap);
      expect(url, 'https://example.com/crops/maize.jpg');
    });

    test('returns empty string for unknown crop type', () {
      final url = imageUrlForCrop('quinoa', imageMap);
      expect(url, isEmpty);
    });

    test('returns known URL or empty string — never a random fallback', () {
      expect(imageUrlForCrop('maize', imageMap), 'https://example.com/crops/maize.jpg');
      expect(imageUrlForCrop('unknown', imageMap), isEmpty);
      expect(imageUrlForCrop('', imageMap), isEmpty);
      expect(imageUrlForCrop('SORGHUM', imageMap), 'https://example.com/crops/sorghum.jpg');
    });

    test('returns empty string for empty image map', () {
      final url = imageUrlForCrop('maize', {});
      expect(url, isEmpty);
    });
  });

  group('cropStage', () {
    test('returns Vegetative for early progress', () {
      final crop = _makeCrop(daysAgo: 5, totalDays: 90);
      expect(cropStage(crop), 'Vegetative');
    });

    test('returns Flowering for mid progress', () {
      final crop = _makeCrop(daysAgo: 45, totalDays: 90);
      expect(cropStage(crop), 'Flowering');
    });

    test('returns Harvest Ready for late progress', () {
      final crop = _makeCrop(daysAgo: 80, totalDays: 90);
      expect(cropStage(crop), 'Harvest Ready');
    });
  });

  group('cropProgress', () {
    test('returns 0 at planting date', () {
      final crop = _makeCrop(daysAgo: 0, totalDays: 90);
      expect(cropProgress(crop), closeTo(0.0, 0.02));
    });

    test('returns 1 at harvest date', () {
      final crop = _makeCrop(daysAgo: 90, totalDays: 90);
      expect(cropProgress(crop), 1.0);
    });

    test('clamps to 1 when past harvest date', () {
      final crop = _makeCrop(daysAgo: 120, totalDays: 90);
      expect(cropProgress(crop), 1.0);
    });

    test('returns 1 when total days is zero', () {
      final now = DateTime.now();
      final crop = CropModel(
        cropType: 'maize',
        fieldName: 'Test Field',
        fieldSize: 1.0,
        fieldSizeUnit: 'hectares',
        plantingDate: now,
        expectedHarvestDate: now,
        estimatedYield: 100,
        yieldUnit: 'kg',
        storageMethod: 'silo',
      );
      expect(cropProgress(crop), 1.0);
    });
  });

  group('formatCropDate', () {
    test('formats date correctly', () {
      expect(formatCropDate(DateTime(2026, 3, 6)), 'Mar 6, 2026');
    });

    test('formats January correctly', () {
      expect(formatCropDate(DateTime(2026, 1, 1)), 'Jan 1, 2026');
    });

    test('formats December correctly', () {
      expect(formatCropDate(DateTime(2025, 12, 25)), 'Dec 25, 2025');
    });
  });
}

CropModel _makeCrop({required int daysAgo, required int totalDays}) {
  final now = DateTime.now();
  final plantingDate = now.subtract(Duration(days: daysAgo));
  final harvestDate = plantingDate.add(Duration(days: totalDays));
  return CropModel(
    cropType: 'maize',
    fieldName: 'Test Field',
    fieldSize: 1.0,
    fieldSizeUnit: 'hectares',
    plantingDate: plantingDate,
    expectedHarvestDate: harvestDate,
    estimatedYield: 100,
    yieldUnit: 'kg',
    storageMethod: 'silo',
  );
}
