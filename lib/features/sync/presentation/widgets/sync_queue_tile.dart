import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/sync_summary.dart';

class SyncQueueTile extends StatelessWidget {
  const SyncQueueTile({super.key, required this.item});

  final SyncQueueItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconFor(item.status),
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neutralSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.tag,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.timeLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                _statusChip(item.status),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(QueueItemStatus status) {
    switch (status) {
      case QueueItemStatus.pending:
        return Icons.description_outlined;
      case QueueItemStatus.offline:
        return Icons.person_add_alt_1_outlined;
      case QueueItemStatus.queued:
        return Icons.location_on_outlined;
    }
  }

  Widget _statusChip(QueueItemStatus status) {
    switch (status) {
      case QueueItemStatus.pending:
        return const StatusChip(
          label: 'Pendente',
          foreground: AppColors.warning,
          background: AppColors.warningSoft,
        );
      case QueueItemStatus.offline:
        return const StatusChip(
          label: 'Offline',
          foreground: AppColors.textSecondary,
          background: AppColors.neutralSoft,
        );
      case QueueItemStatus.queued:
        return const StatusChip(
          label: 'Na Fila',
          foreground: AppColors.primary,
          background: AppColors.primarySoft,
        );
    }
  }
}
