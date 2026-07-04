import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/catalog_exception.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/catalog_repository.dart';

/// Implementação real de [CatalogRepository], contra `GET /api/products` e
/// `GET /api/products/{id}` da Web API .NET 10.
class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/api/products');
      return response.data!
          .map((json) => _productFromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw CatalogException(_errorMessage(e));
    }
  }

  @override
  Future<ProductDetail> fetchProductDetail(String productId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/products/$productId',
      );
      return _productDetailFromJson(response.data!);
    } on DioException catch (e) {
      throw CatalogException(_errorMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'Produto não encontrado.';
    }
    return 'Não foi possível carregar o catálogo. Tente novamente.';
  }

  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      sku: json['sku'] as String,
      brand: json['brand'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      availableUnits: json['availableUnits'] as int,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      badge: _badgeFromJson(json['badge'] as String),
    );
  }

  ProductBadge _badgeFromJson(String value) {
    switch (value) {
      case 'none':
        return ProductBadge.none;
      case 'offer':
        return ProductBadge.offer;
      case 'outOfStock':
        return ProductBadge.outOfStock;
      default:
        throw CatalogException('Badge de produto desconhecido: $value');
    }
  }

  ProductDetail _productDetailFromJson(Map<String, dynamic> json) {
    final product = _productFromJson(json['product'] as Map<String, dynamic>);
    final stockByWarehouse = (json['stockByWarehouse'] as List<dynamic>)
        .map(
          (item) => _warehouseStockFromJson(item as Map<String, dynamic>),
        )
        .toList();

    return ProductDetail(
      product: product,
      categoryLabel: product.category.toUpperCase(),
      images: (json['images'] as List<dynamic>).cast<String>(),
      appliedPromotions: (json['appliedPromotions'] as List<dynamic>)
          .cast<String>(),
      stockByWarehouse: stockByWarehouse,
      commercialDescription: json['commercialDescription'] as String,
      technicalSpecs: (json['technicalSpecs'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as String),
      ),
    );
  }

  WarehouseStock _warehouseStockFromJson(Map<String, dynamic> json) {
    return WarehouseStock(
      warehouseName: json['warehouseName'] as String,
      state: json['state'] as String,
      bundlesAvailable: json['bundlesAvailable'] as int,
      level: _stockLevelFromJson(json['level'] as String),
    );
  }

  StockLevel _stockLevelFromJson(String value) {
    switch (value) {
      case 'high':
        return StockLevel.high;
      case 'medium':
        return StockLevel.medium;
      case 'critical':
        return StockLevel.critical;
      default:
        throw CatalogException('Nível de estoque desconhecido: $value');
    }
  }
}
