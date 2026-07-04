import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/reports_summary.dart';

class ReportKpiCard extends StatelessWidget {
  const ReportKpiCard({super.key, required this.kpi});

  final ReportKpi kpi;

  @override
  Widget build(BuildContext context) {
    final isPositive = kpi.growthPercent >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPositive
                      ? context.colors.successSoft
                      : context.colors.errorSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${kpi.growthPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPositive ? context.colors.success : context.colors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kpi.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              kpi.label,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
