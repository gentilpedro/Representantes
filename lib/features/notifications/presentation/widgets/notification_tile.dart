import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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

  (IconData, Color, String) get _categoryMeta {
    switch (notification.category) {
      case NotificationCategory.order:
        return (Icons.shopping_cart_outlined, AppColors.primary, 'PEDIDO');
      case NotificationCategory.promotion:
        return (Icons.sell_outlined, AppColors.warning, 'PROMOÇÃO');
      case NotificationCategory.announcement:
        return (Icons.campaign_outlined, AppColors.textSecondary, 'COMUNICADO');
      case NotificationCategory.launch:
        return (Icons.inventory_2_outlined, AppColors.success, 'LANÇAMENTO');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _categoryMeta;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
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
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  if (notification.isUrgent) ...[
                    const SizedBox(height: 6),
                    const StatusChip(
                      label: 'Urgente',
                      foreground: Colors.white,
                      background: AppColors.error,
                      filled: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
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
}
