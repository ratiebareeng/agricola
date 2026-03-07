import 'package:agricola/core/providers/language_provider.dart';

class CropCatalogEntry {
  final int id;
  final String key;
  final String category;
  final String nameEn;
  final String nameSw;
  final int harvestDays;
  final int? plantPopulationPerHa;
  final double? dailyWaterMm;
  final String? imageUrl;
  final int sortOrder;

  const CropCatalogEntry({
    required this.id,
    required this.key,
    required this.category,
    required this.nameEn,
    required this.nameSw,
    required this.harvestDays,
    this.plantPopulationPerHa,
    this.dailyWaterMm,
    this.imageUrl,
    required this.sortOrder,
  });

  factory CropCatalogEntry.fromJson(Map<String, dynamic> json) {
    return CropCatalogEntry(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      key: json['key'] as String,
      category: json['category'] as String,
      nameEn: json['nameEn'] as String,
      nameSw: json['nameSw'] as String,
      harvestDays: json['harvestDays'] as int,
      plantPopulationPerHa: json['plantPopulationPerHa'] as int?,
      dailyWaterMm: json['dailyWaterMm'] != null
          ? (json['dailyWaterMm'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'] as String?,
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'category': category,
      'nameEn': nameEn,
      'nameSw': nameSw,
      'harvestDays': harvestDays,
      'plantPopulationPerHa': plantPopulationPerHa,
      'dailyWaterMm': dailyWaterMm,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
    };
  }

  String displayName(AppLanguage lang) {
    return lang == AppLanguage.setswana ? nameSw : nameEn;
  }
}
