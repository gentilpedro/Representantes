import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/order_summary.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case OrderStatus.pending:
        return StatusChip(
          label: 'PENDENTE',
          icon: Icons.cloud_off_outlined,
          foreground: context.colors.textSecondary,
          background: context.colors.neutralSoft,
        );
      case OrderStatus.sent:
        return StatusChip(
          label: 'ENVIADO',
          icon: Icons.check_circle_outline,
          foreground: context.colors.success,
          background: context.colors.successSoft,
        );
      case OrderStatus.error:
        return StatusChip(
          label: 'ERRO',
          icon: Icons.error_outline,
          foreground: Colors.white,
          background: context.colors.error,
          filled: true,
        );
      case OrderStatus.draft:
        return StatusChip(
          label: 'RASCUNHO',
          icon: Icons.description_outlined,
          foreground: context.colors.textSecondary,
          background: context.colors.neutralSoft,
        );
    }
  }
}
