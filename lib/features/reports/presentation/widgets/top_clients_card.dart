import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/reports_summary.dart';

class TopClientsCard extends StatelessWidget {
  const TopClientsCard({super.key, required this.clients, this.onSeeAll});

  final List<TopClient> clients;
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
              'Principais Clientes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            TextButton(onPressed: onSeeAll, child: const Text('Ver Todos')),
          ],
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < clients.length; i++) ...[
                _ClientTile(client: clients[i]),
                if (i != clients.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ClientTile extends StatelessWidget {
  const _ClientTile({required this.client});

  final TopClient client;

  @override
  Widget build(BuildContext context) {
    final isUp = client.trend == TrendDirection.up;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.neutralSoft,
            child: Text(
              client.name.substring(0, 1),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Volume total: ${AppFormatters.currency(client.volume)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(
            label: isUp ? 'ALTA' : 'QUEDA',
            icon: isUp ? Icons.trending_up : Icons.trending_down,
            foreground: isUp ? AppColors.success : AppColors.error,
            background: isUp ? AppColors.successSoft : AppColors.errorSoft,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
