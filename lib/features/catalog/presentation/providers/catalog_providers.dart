import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/api_catalog_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => ApiCatalogRepository(
    ref.watch(apiClientProvider),
    ref.watch(appDatabaseProvider),
  ),
);

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(catalogRepositoryProvider).fetchProducts();
});

final productDetailProvider = FutureProvider.autoDispose
    .family<ProductDetail, String>((ref, productId) {
      return ref.watch(catalogRepositoryProvider).fetchProductDetail(productId);
    });

final catalogSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final catalogCategoryProvider = StateProvider.autoDispose<String>(
  (ref) => 'Todos',
);

final filteredProductsProvider =
    Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
      final productsAsync = ref.watch(productsProvider);
      final query = ref.watch(catalogSearchQueryProvider).trim().toLowerCase();
      final category = ref.watch(catalogCategoryProvider);

      return productsAsync.whenData((products) {
        return products.where((product) {
          final matchesQuery =
              query.isEmpty ||
              product.name.toLowerCase().contains(query) ||
              product.brand.toLowerCase().contains(query);
          final matchesCategory =
              category == 'Todos' || product.category == category;
          return matchesQuery && matchesCategory;
        }).toList();
      });
    });
