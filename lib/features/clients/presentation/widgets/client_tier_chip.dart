import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/client_list_item.dart';

class ClientTierChip extends StatelessWidget {
  const ClientTierChip({super.key, required this.tier});

  final ClientTier tier;

  @override
  Widget build(BuildContext context) {
    switch (tier) {
      case ClientTier.regular:
        return const StatusChip(
          label: 'Regular',
          foreground: AppColors.textSecondary,
          background: AppColors.neutralSoft,
        );
      case ClientTier.gold:
        return const StatusChip(
          label: 'Ouro',
          foreground: AppColors.warning,
          background: AppColors.warningSoft,
        );
      case ClientTier.underReview:
        return const StatusChip(
          label: 'Em Análise',
          foreground: AppColors.warning,
          background: AppColors.warningSoft,
        );
      case ClientTier.blocked:
        return const StatusChip(
          label: 'Bloqueado',
          foreground: Colors.white,
          background: AppColors.error,
          filled: true,
        );
    }
  }
}
