import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
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
                color: context.colors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconFor(item.status),
                color: context.colors.primary,
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
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textMuted,
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
                          color: context.colors.neutralSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.colors.textSecondary,
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
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                _statusChip(context, item.status),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: context.colors.textMuted,
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

  Widget _statusChip(BuildContext context, QueueItemStatus status) {
    switch (status) {
      case QueueItemStatus.pending:
        return StatusChip(
          label: 'Pendente',
          foreground: context.colors.warning,
          background: context.colors.warningSoft,
        );
      case QueueItemStatus.offline:
        return StatusChip(
          label: 'Offline',
          foreground: context.colors.textSecondary,
          background: context.colors.neutralSoft,
        );
      case QueueItemStatus.queued:
        return StatusChip(
          label: 'Na Fila',
          foreground: context.colors.primary,
          background: context.colors.primarySoft,
        );
    }
  }
}
