import 'package:agricola/core/constants/api_constants.dart';
import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:dio/dio.dart';

class MarketplaceApiService {
  final Dio _dio;

  MarketplaceApiService(this._dio);

  /// GET /api/v1/marketplace - fetch listings with optional filters
  Future<List<MarketplaceListing>> getListings({
    MarketplaceFilter? filter,
  }) async {
    final queryParams = filter?.toQueryParameters() ?? {};

    final response = await _dio.get(
      '/${ApiConstants.marketplaceEndpoint}',
      queryParameters: queryParams,
    );

    final list = response.data['data'] as List<dynamic>;
    return list
        .map(
            (json) => MarketplaceListing.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/marketplace/<id> - fetch single listing
  Future<MarketplaceListing> getListing(String id) async {
    final response =
        await _dio.get('/${ApiConstants.marketplaceEndpoint}/$id');
    return MarketplaceListing.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  /// POST /api/v1/marketplace - create a new listing
  Future<MarketplaceListing> createListing(MarketplaceListing listing) async {
    final response = await _dio.post(
      '/${ApiConstants.marketplaceEndpoint}',
      data: listing.toJson(),
    );
    return MarketplaceListing.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  /// PUT /api/v1/marketplace/<id> - update a listing
  Future<MarketplaceListing> updateListing(
      String id, MarketplaceListing listing) async {
    final response = await _dio.put(
      '/${ApiConstants.marketplaceEndpoint}/$id',
      data: listing.toJson(),
    );
    return MarketplaceListing.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  /// DELETE /api/v1/marketplace/<id> - delete a listing
  Future<void> deleteListing(String id) async {
    await _dio.delete('/${ApiConstants.marketplaceEndpoint}/$id');
  }
}
