import 'package:agricola/core/constants/api_constants.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:dio/dio.dart';

class OrdersApiService {
  final Dio _dio;

  OrdersApiService(this._dio);

  /// GET /api/v1/orders - Get orders for the authenticated user
  /// [role] - Optional filter: 'buyer' or 'seller'
  Future<List<OrderModel>> getUserOrders({String? role}) async {
    final queryParams = <String, dynamic>{};
    if (role != null) {
      queryParams['role'] = role;
    }

    final response = await _dio.get(
      ApiConstants.ordersEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final list = response.data['data'] as List<dynamic>;
    return list
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/orders/:id - Get a single order
  Future<OrderModel> getOrder(String id) async {
    final response = await _dio.get('${ApiConstants.ordersEndpoint}/$id');
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// PUT /api/v1/orders/:id/status - Update order status (seller only)
  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final response = await _dio.put(
      '${ApiConstants.ordersEndpoint}/$id/status',
      data: {'status': status},
    );
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// DELETE /api/v1/orders/:id - Cancel order (buyer only, pending only)
  Future<void> cancelOrder(String id) async {
    await _dio.delete('${ApiConstants.ordersEndpoint}/$id');
  }
}
