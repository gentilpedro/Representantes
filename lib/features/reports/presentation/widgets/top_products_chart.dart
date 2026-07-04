import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/chart_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/reports_summary.dart';

class TopProductsChart extends StatelessWidget {
  const TopProductsChart({super.key, required this.products});

  final List<TopProduct> products;

  @override
  Widget build(BuildContext context) {
    final maxAmount = products
        .map((p) => p.amount)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Produtos Mais Vendidos',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Text(
              'Volume financeiro por SKU',
              style: TextStyle(fontSize: 11, color: context.colors.textMuted),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < products.length; i++) ...[
              _ProductBar(
                product: products[i],
                color:
                    ChartColors.categorical[i % ChartColors.categorical.length],
                fraction: maxAmount == 0 ? 0 : products[i].amount / maxAmount,
              ),
              if (i != products.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductBar extends StatelessWidget {
  const _ProductBar({
    required this.product,
    required this.color,
    required this.fraction,
  });

  final TopProduct product;
  final Color color;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              product.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            Text(
              AppFormatters.currency(product.amount),
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(height: 10, color: context.colors.neutralSoft),
                  Container(
                    height: 10,
                    width: constraints.maxWidth * fraction.clamp(0, 1),
                    color: color,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
