import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/catalog_repository.dart';

/// Dados fixos espelhando as telas "Catálogo de Produtos" e "Detalhe do
/// Produto" do protótipo.
class MockCatalogRepository implements CatalogRepository {
  static const _products = [
    Product(
      id: 'tio-joao-tipo1',
      sku: 'ARZ-TJ-T1',
      brand: 'TIO JOÃO',
      name: 'Arroz Tio João Tipo 1',
      category: 'Arroz',
      imageUrl:
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
      price: 24.90,
      availableUnits: 1500,
    ),
    Product(
      id: 'meu-biju-integral',
      sku: 'ARZ-MB-INT',
      brand: 'MEU BIJU',
      name: 'Arroz Meu Biju Integral',
      category: 'Arroz',
      imageUrl:
          'https://images.unsplash.com/photo-1595231776515-ddffb1f4eb73?w=400',
      price: 15.90,
      originalPrice: 18.50,
      availableUnits: 450,
      badge: ProductBadge.offer,
      isFavorite: true,
    ),
    Product(
      id: 'feijao-carioca',
      sku: 'FEJ-TJ-CAR',
      brand: 'TIO JOÃO',
      name: 'Feijão Tio João Carioca',
      category: 'Feijões',
      imageUrl:
          'https://images.unsplash.com/photo-1610725664285-7c57e6eea3f3?w=400',
      price: 9.90,
      availableUnits: 12,
    ),
    Product(
      id: 'azeite-nova-oliva',
      sku: 'AZE-NO-EV',
      brand: 'NOVA OLIVA',
      name: 'Azeite Nova Oliva Extra Virgem',
      category: 'Outros',
      imageUrl:
          'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400',
      price: 35.00,
      availableUnits: 80,
      isFavorite: true,
    ),
    Product(
      id: 'arroz-parboilizado',
      sku: 'ARZ-TJ-PB',
      brand: 'TIO JOÃO',
      name: 'Arroz Tio João Parboilizado',
      category: 'Arroz',
      imageUrl:
          'https://images.unsplash.com/photo-1607330289024-1535c6b4e1c1?w=400',
      price: 22.90,
      availableUnits: 200,
    ),
    Product(
      id: 'mistura-facil',
      sku: 'MIX-TJ-FAC',
      brand: 'TIO JOÃO',
      name: 'Mistura Tio João Fácil',
      category: 'Arroz',
      imageUrl:
          'https://images.unsplash.com/photo-1586201375800-744e7c8fb191?w=400',
      price: 12.40,
      availableUnits: 0,
      badge: ProductBadge.outOfStock,
    ),
  ];

  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products;
  }

  @override
  Future<ProductDetail> fetchProductDetail(String productId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final product = _products.firstWhere((p) => p.id == productId);

    return ProductDetail(
      product: product,
      categoryLabel: product.category.toUpperCase(),
      images: [product.imageUrl],
      appliedPromotions: const ['Volume 50+', 'Campanha Sul'],
      stockByWarehouse: const [
        WarehouseStock(
          warehouseName: 'CD Pelotas',
          state: 'RS',
          bundlesAvailable: 1250,
          level: StockLevel.high,
        ),
        WarehouseStock(
          warehouseName: 'CD Recife',
          state: 'PE',
          bundlesAvailable: 450,
          level: StockLevel.medium,
        ),
        WarehouseStock(
          warehouseName: 'CD São Paulo',
          state: 'SP',
          bundlesAvailable: 15,
          level: StockLevel.critical,
        ),
      ],
      commercialDescription:
          'O ${product.name} é selecionado eletronicamente grão a grão. Possui alto '
          'rendimento e fica sempre soltinho, ideal para o dia a dia de famílias '
          'brasileiras.',
      technicalSpecs: {
        'Marca': product.brand,
        'SKU': product.sku,
        'Categoria': product.category,
        'Unidades disponíveis': '${product.availableUnits}',
      },
    );
  }
}
