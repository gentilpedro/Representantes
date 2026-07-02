import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/chart_colors.dart';
import '../../domain/entities/reports_summary.dart';

class RegionMixChart extends StatelessWidget {
  const RegionMixChart({super.key, required this.regions});

  final List<RegionMix> regions;

  Color _colorFor(int index) {
    // Sul/Sudeste/Nordeste usam a paleta categórica validada; um eventual
    // 4º item ("Outros") usa cinza neutro — não é uma identidade própria.
    if (index < 3) return ChartColors.categorical[index == 2 ? 7 : index];
    return ChartColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mix por Região',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        for (var i = 0; i < regions.length; i++)
                          PieChartSectionData(
                            value: regions[i].percent,
                            color: _colorFor(i),
                            showTitle: false,
                            radius: 22,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < regions.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _colorFor(i),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  regions[i].label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${(regions[i].percent * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
