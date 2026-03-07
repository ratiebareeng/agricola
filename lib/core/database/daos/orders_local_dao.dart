import 'dart:convert';

import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/features/orders/models/order_model.dart';

class OrdersLocalDao {
  final AppDatabase _db;

  OrdersLocalDao(this._db);

  Future<List<OrderModel>> getAll() async {
    final rows = await _db.select(_db.localOrders).get();
    return rows
        .map((r) =>
            OrderModel.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheAll(List<OrderModel> orders) async {
    await _db.transaction(() async {
      await _db.delete(_db.localOrders).go();
      for (final order in orders) {
        await _db.into(_db.localOrders).insertOnConflictUpdate(
          LocalOrdersCompanion.insert(
            id: order.id ?? '',
            data: jsonEncode(order.toJson()),
          ),
        );
      }
    });
  }
}
