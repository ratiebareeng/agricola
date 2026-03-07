import 'dart:convert';

import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';

class MarketplaceLocalDao {
  final AppDatabase _db;

  MarketplaceLocalDao(this._db);

  Future<List<MarketplaceListing>> getAll() async {
    final rows = await _db.select(_db.localMarketplace).get();
    return rows
        .map((r) =>
            MarketplaceListing.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheAll(List<MarketplaceListing> listings) async {
    await _db.transaction(() async {
      await _db.delete(_db.localMarketplace).go();
      for (final listing in listings) {
        await _db.into(_db.localMarketplace).insertOnConflictUpdate(
          LocalMarketplaceCompanion.insert(
            id: listing.id,
            data: jsonEncode(listing.toJson()),
          ),
        );
      }
    });
  }
}
