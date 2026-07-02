import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../orders/presentation/providers/new_order_providers.dart';
import '../../domain/entities/product_detail.dart';
import '../providers/catalog_providers.dart';
import '../widgets/stock_row.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  final _discountController = TextEditingController(text: '0');

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe do Produto'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ResponsiveContent(
        child: detailAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Text('Não foi possível carregar o produto.\n$error'),
          ),
          data: (detail) => _buildContent(context, detail),
        ),
      ),
      bottomNavigationBar: detailAsync.maybeWhen(
        data: (detail) => _buildBottomBar(context, detail),
        orElse: () => null,
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductDetail detail) {
    final product = detail.product;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: CachedNetworkImage(
            imageUrl: detail.images.first,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const ColoredBox(color: AppColors.neutralSoft),
            errorWidget: (context, url, error) => const ColoredBox(
              color: AppColors.neutralSoft,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.categoryLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    product.isFavorite ? Icons.star : Icons.star_border,
                    color: product.isFavorite
                        ? AppColors.warning
                        : AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(product.price),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  if (product.originalPrice != null) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        AppFormatters.currency(product.originalPrice!),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '↘ ${product.discountPercent}% OFF',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (detail.appliedPromotions.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'PROMOÇÕES APLICÁVEIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final promo in detail.appliedPromotions)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorSoft,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              promo,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'ESTOQUE POR DEPÓSITO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      for (
                        var i = 0;
                        i < detail.stockByWarehouse.length;
                        i++
                      ) ...[
                        StockRow(stock: detail.stockByWarehouse[i]),
                        if (i != detail.stockByWarehouse.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ExpandableSection(
                title: 'DESCRIÇÃO COMERCIAL',
                content: detail.commercialDescription,
              ),
              const SizedBox(height: 8),
              _ExpandableSection(
                title: 'ESPECIFICAÇÕES TÉCNICAS',
                content: detail.technicalSpecs.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .join('\n'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ProductDetail detail) {
    final discount =
        double.tryParse(_discountController.text.replaceAll(',', '.')) ?? 0;
    final total = detail.product.price * _quantity * (1 - discount / 100);

    return ResponsiveContent(
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _QuantityStepper(
                    quantity: _quantity,
                    onChanged: (value) => setState(() => _quantity = value),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: '% Desconto',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TOTAL DO ITEM',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        AppFormatters.currency(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(newOrderControllerProvider.notifier)
                        .addProduct(detail.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${detail.product.name} adicionado ao pedido.',
                        ),
                      ),
                    );
                    context.pop();
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('ADICIONAR AO PEDIDO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(Icons.add, size: 18),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Card(
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
