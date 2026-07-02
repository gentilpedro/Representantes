import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
            backgroundColor: AppColors.neutralSoft,
            child: Text(
              order.clientName.substring(0, 1),
              style: const TextStyle(
                color: AppColors.textSecondary,
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              _statusChip(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(RecentOrderStatus status) {
    switch (status) {
      case RecentOrderStatus.synced:
        return const StatusChip(
          label: 'Sincronizado',
          foreground: AppColors.success,
          background: AppColors.successSoft,
        );
      case RecentOrderStatus.pending:
        return const StatusChip(
          label: 'Pendente',
          foreground: AppColors.warning,
          background: AppColors.warningSoft,
        );
      case RecentOrderStatus.draft:
        return const StatusChip(
          label: 'Rascunho',
          foreground: AppColors.textSecondary,
          background: AppColors.neutralSoft,
        );
    }
  }
}
