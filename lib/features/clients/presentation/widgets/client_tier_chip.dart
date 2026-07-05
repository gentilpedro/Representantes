import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/client_list_item.dart';

class ClientTierChip extends StatelessWidget {
  const ClientTierChip({super.key, required this.tier});

  final ClientTier tier;

  @override
  Widget build(BuildContext context) {
    switch (tier) {
      case ClientTier.regular:
        return StatusChip(
          label: 'Regular',
          foreground: context.colors.textSecondary,
          background: context.colors.neutralSoft,
        );
      case ClientTier.gold:
        return StatusChip(
          label: 'Ouro',
          foreground: context.colors.warning,
          background: context.colors.warningSoft,
        );
      case ClientTier.underReview:
        return StatusChip(
          label: 'Em Análise',
          foreground: context.colors.warning,
          background: context.colors.warningSoft,
        );
      case ClientTier.blocked:
        return StatusChip(
          label: 'Bloqueado',
          foreground: Colors.white,
          background: context.colors.error,
          filled: true,
        );
    }
  }
}
