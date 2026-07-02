import '../entities/product.dart';
import '../entities/product_detail.dart';

/// Contrato do catálogo. A implementação real deve consumir a Web API .NET 10
/// (ex: `GET /api/products`, `GET /api/products/{id}`).
abstract class CatalogRepository {
  Future<List<Product>> fetchProducts();

  Future<ProductDetail> fetchProductDetail(String productId);
}
