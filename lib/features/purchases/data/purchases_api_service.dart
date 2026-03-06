import 'package:agricola/core/constants/api_constants.dart';
import 'package:agricola/features/purchases/models/purchase_model.dart';
import 'package:dio/dio.dart';

class PurchasesApiService {
  final Dio _dio;

  PurchasesApiService(this._dio);

  Future<List<PurchaseModel>> getPurchases() async {
    final response = await _dio.get('/${ApiConstants.purchasesEndpoint}');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((json) => PurchaseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PurchaseModel> getPurchase(String id) async {
    final response = await _dio.get('/${ApiConstants.purchasesEndpoint}/$id');
    return PurchaseModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<PurchaseModel> createPurchase(PurchaseModel purchase) async {
    final response = await _dio.post(
      '/${ApiConstants.purchasesEndpoint}',
      data: purchase.toJson(),
    );
    return PurchaseModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<PurchaseModel> updatePurchase(String id, PurchaseModel purchase) async {
    final response = await _dio.put(
      '/${ApiConstants.purchasesEndpoint}/$id',
      data: purchase.toJson(),
    );
    return PurchaseModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deletePurchase(String id) async {
    await _dio.delete('/${ApiConstants.purchasesEndpoint}/$id');
  }
}
