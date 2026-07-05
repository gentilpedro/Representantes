import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/product_detail.dart';

class StockRow extends StatelessWidget {
  const StockRow({super.key, required this.stock});

  final WarehouseStock stock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 18,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stock.warehouseName} - ${stock.state}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${stock.bundlesAvailable} fardos disponíveis',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _levelChip(context, stock.level),
        ],
      ),
    );
  }

  Widget _levelChip(BuildContext context, StockLevel level) {
    switch (level) {
      case StockLevel.high:
        return StatusChip(
          label: 'Alto',
          foreground: context.colors.success,
          background: context.colors.successSoft,
        );
      case StockLevel.medium:
        return StatusChip(
          label: 'Médio',
          foreground: context.colors.warning,
          background: context.colors.warningSoft,
        );
      case StockLevel.critical:
        return StatusChip(
          label: 'Crítico',
          foreground: Colors.white,
          background: context.colors.error,
          filled: true,
        );
    }
  }
}
