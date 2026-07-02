import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../orders/presentation/providers/new_order_providers.dart';
import '../providers/catalog_providers.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  static const _categories = ['Todos', 'Arroz', 'Feijões', 'Outros'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final category = ref.watch(catalogCategoryProvider);
    final cartCount = ref.watch(newOrderControllerProvider).items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push(AppRoutes.newOrder),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.star_outline)),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: 1200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) =>
                              ref
                                      .read(catalogSearchQueryProvider.notifier)
                                      .state =
                                  value,
                          decoration: const InputDecoration(
                            hintText: 'Pesquisar produtos ou marcas...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.tune),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final c in _categories) ...[
                          ChoiceChip(
                            label: Text(c),
                            selected: category == c,
                            onSelected: (_) =>
                                ref
                                        .read(catalogCategoryProvider.notifier)
                                        .state =
                                    c,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.border),
                            labelStyle: TextStyle(
                              color: category == c
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Text('Não foi possível carregar o catálogo.\n$error'),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Nenhum produto encontrado.'),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 210,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () =>
                            context.push(AppRoutes.productDetail(product.id)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
