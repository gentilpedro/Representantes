import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/lead.dart';

class LeadStatusChip extends StatelessWidget {
  const LeadStatusChip({super.key, required this.status});

  final LeadStatus status;

  static String label(LeadStatus status) {
    switch (status) {
      case LeadStatus.new_:
        return 'Novo';
      case LeadStatus.contacted:
        return 'Contatado';
      case LeadStatus.qualified:
        return 'Qualificado';
      case LeadStatus.converted:
        return 'Convertido';
      case LeadStatus.lost:
        return 'Perdido';
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LeadStatus.new_:
        return StatusChip(
          label: label(status),
          foreground: context.colors.primary,
          background: context.colors.primarySoft,
        );
      case LeadStatus.contacted:
        return StatusChip(
          label: label(status),
          foreground: context.colors.warning,
          background: context.colors.warningSoft,
        );
      case LeadStatus.qualified:
        return StatusChip(
          label: label(status),
          foreground: context.colors.info,
          background: context.colors.infoSoft,
        );
      case LeadStatus.converted:
        return StatusChip(
          label: label(status),
          foreground: context.colors.success,
          background: context.colors.successSoft,
        );
      case LeadStatus.lost:
        return StatusChip(
          label: label(status),
          foreground: Colors.white,
          background: context.colors.error,
          filled: true,
        );
    }
  }
}
