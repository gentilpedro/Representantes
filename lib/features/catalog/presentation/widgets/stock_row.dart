import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
          const Icon(
            Icons.location_on_outlined,
            size: 18,
            color: AppColors.textSecondary,
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _levelChip(stock.level),
        ],
      ),
    );
  }

  Widget _levelChip(StockLevel level) {
    switch (level) {
      case StockLevel.high:
        return const StatusChip(
          label: 'Alto',
          foreground: AppColors.success,
          background: AppColors.successSoft,
        );
      case StockLevel.medium:
        return const StatusChip(
          label: 'Médio',
          foreground: AppColors.warning,
          background: AppColors.warningSoft,
        );
      case StockLevel.critical:
        return const StatusChip(
          label: 'Crítico',
          foreground: Colors.white,
          background: AppColors.error,
          filled: true,
        );
    }
  }
}
