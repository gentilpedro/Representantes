import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_summary.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onPrimaryAction,
    this.onSend,
  });

  final OrderSummary order;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    order.clientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              order.code,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoLine(label: 'Data:', value: order.dateLabel),
                      const SizedBox(height: 2),
                      _InfoLine(
                        label: 'Itens:',
                        value: '${order.itemsCount} produtos',
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      AppFormatters.currency(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onPrimaryAction,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  icon: Icon(
                    order.status == OrderStatus.pending ||
                            order.status == OrderStatus.draft
                        ? Icons.edit_outlined
                        : Icons.description_outlined,
                  ),
                  label: Text(
                    order.status == OrderStatus.pending ||
                            order.status == OrderStatus.draft
                        ? 'Editar'
                        : 'Visualizar',
                  ),
                ),
                if (order.status == OrderStatus.pending) ...[
                  const SizedBox(width: 20),
                  TextButton.icon(
                    onPressed: onSend,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Enviar'),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
