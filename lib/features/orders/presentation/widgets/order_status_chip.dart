import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/order_summary.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case OrderStatus.pending:
        return const StatusChip(
          label: 'PENDENTE',
          icon: Icons.cloud_off_outlined,
          foreground: AppColors.textSecondary,
          background: AppColors.neutralSoft,
        );
      case OrderStatus.sent:
        return const StatusChip(
          label: 'ENVIADO',
          icon: Icons.check_circle_outline,
          foreground: AppColors.success,
          background: AppColors.successSoft,
        );
      case OrderStatus.error:
        return const StatusChip(
          label: 'ERRO',
          icon: Icons.error_outline,
          foreground: Colors.white,
          background: AppColors.error,
          filled: true,
        );
      case OrderStatus.draft:
        return const StatusChip(
          label: 'RASCUNHO',
          icon: Icons.description_outlined,
          foreground: AppColors.textSecondary,
          background: AppColors.neutralSoft,
        );
    }
  }
}
