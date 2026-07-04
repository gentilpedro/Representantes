import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/reports_summary.dart';

class SalesInsightCard extends StatelessWidget {
  const SalesInsightCard({
    super.key,
    required this.insight,
    required this.onScheduleVisit,
  });

  final SalesInsight insight;
  final VoidCallback onScheduleVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.infoSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_objects_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Insight de Vendas',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.message,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.primaryDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onScheduleVisit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Agendar Visita'),
          ),
        ],
      ),
    );
  }
}
