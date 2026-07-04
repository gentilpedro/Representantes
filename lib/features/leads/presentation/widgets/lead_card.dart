import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/lead.dart';
import 'lead_status_chip.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({super.key, required this.lead, required this.onTap});

  final Lead lead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      lead.companyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  LeadStatusChip(status: lead.status),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: context.colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lead.contactName,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.call_outlined,
                    size: 14,
                    color: context.colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lead.phone,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
