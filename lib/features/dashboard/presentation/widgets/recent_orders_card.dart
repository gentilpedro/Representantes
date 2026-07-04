import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/dashboard_summary.dart';

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({super.key, required this.orders, this.onSeeAll});

  final List<RecentOrderSummary> orders;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pedidos Recentes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ver todos'),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < orders.length; i++) ...[
                _RecentOrderTile(order: orders[i]),
                if (i != orders.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order});

  final RecentOrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.colors.neutralSoft,
            child: Text(
              order.clientName.substring(0, 1),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.clientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.code} · ${order.timeLabel}',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(order.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 4),
              _statusChip(context, order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, RecentOrderStatus status) {
    switch (status) {
      case RecentOrderStatus.synced:
        return StatusChip(
          label: 'Sincronizado',
          foreground: context.colors.success,
          background: context.colors.successSoft,
        );
      case RecentOrderStatus.pending:
        return StatusChip(
          label: 'Pendente',
          foreground: context.colors.warning,
          background: context.colors.warningSoft,
        );
      case RecentOrderStatus.draft:
        return StatusChip(
          label: 'Rascunho',
          foreground: context.colors.textSecondary,
          background: context.colors.neutralSoft,
        );
    }
  }
}
