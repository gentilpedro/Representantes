import 'package:josapar_representantes/features/catalog/domain/catalog_exception.dart';
import 'package:josapar_representantes/features/catalog/domain/entities/product.dart';
import 'package:josapar_representantes/features/catalog/domain/entities/product_detail.dart';
import 'package:josapar_representantes/features/catalog/domain/repositories/catalog_repository.dart';

class FakeCatalogRepository implements CatalogRepository {
  static final products = <Product>[
    const Product(
      id: 'p1',
      sku: 'ARZ-001',
      brand: 'Josapar',
      name: 'Arroz Branco Tipo 1 5kg',
      category: 'Arroz',
      imageUrl: 'https://picsum.photos/seed/ARZ-001/400',
      price: 24.90,
      availableUnits: 500,
    ),
    const Product(
      id: 'p2',
      sku: 'ARZ-002',
      brand: 'Josapar',
      name: 'Arroz Integral Tipo 1 1kg',
      category: 'Arroz',
      imageUrl: 'https://picsum.photos/seed/ARZ-002/400',
      price: 8.50,
      availableUnits: 40,
      originalPrice: 10.90,
      badge: ProductBadge.offer,
    ),
    const Product(
      id: 'p3',
      sku: 'FJO-001',
      brand: 'Josapar',
      name: 'Feijão Carioca 1kg',
      category: 'Feijões',
      imageUrl: 'https://picsum.photos/seed/FJO-001/400',
      price: 7.20,
      availableUnits: 0,
      badge: ProductBadge.outOfStock,
    ),
  ];

  @override
  Future<List<Product>> fetchProducts() async => products;

  @override
  Future<ProductDetail> fetchProductDetail(String productId) async {
    final matches = products.where((p) => p.id == productId);
    if (matches.isEmpty) {
      throw CatalogException('Produto não encontrado.');
    }
    final product = matches.first;

    return ProductDetail(
      product: product,
      categoryLabel: product.category.toUpperCase(),
      images: [product.imageUrl],
      appliedPromotions: const [],
      stockByWarehouse: const [
        WarehouseStock(
          warehouseName: 'CD Porto Alegre',
          state: 'RS',
          bundlesAvailable: 12,
          level: StockLevel.high,
        ),
      ],
      commercialDescription: '${product.name} — qualidade Josapar, embalagem padrão.',
      technicalSpecs: {'Categoria': product.category, 'Marca': product.brand},
    );
  }
}
