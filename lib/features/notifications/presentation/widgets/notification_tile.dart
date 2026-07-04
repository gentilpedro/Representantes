import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  (IconData, Color, String) _categoryMeta(BuildContext context) {
    switch (notification.category) {
      case NotificationCategory.order:
        return (Icons.shopping_cart_outlined, context.colors.primary, 'PEDIDO');
      case NotificationCategory.promotion:
        return (Icons.sell_outlined, context.colors.warning, 'PROMOÇÃO');
      case NotificationCategory.announcement:
        return (Icons.campaign_outlined, context.colors.textSecondary, 'COMUNICADO');
      case NotificationCategory.launch:
        return (Icons.inventory_2_outlined, context.colors.success, 'LANÇAMENTO');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _categoryMeta(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? context.colors.surface
              : context.colors.primarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        notification.timeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  if (notification.isUrgent) ...[
                    const SizedBox(height: 6),
                    StatusChip(
                      label: 'Urgente',
                      foreground: Colors.white,
                      background: context.colors.error,
                      filled: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
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
}
