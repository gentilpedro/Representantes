import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/reports_summary.dart';
import '../providers/reports_providers.dart';
import '../widgets/report_kpi_card.dart';
import '../widgets/region_mix_chart.dart';
import '../widgets/sales_insight_card.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/top_clients_card.dart';
import '../widgets/top_products_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportsSummaryProvider);
    final period = ref.watch(reportPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios & Indicadores'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.tune))],
      ),
      body: ResponsiveContent(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _PeriodChip(
                      label: 'Hoje',
                      value: ReportPeriod.today,
                      groupValue: period,
                    ),
                    const SizedBox(width: 8),
                    _PeriodChip(
                      label: 'Esta Semana',
                      value: ReportPeriod.week,
                      groupValue: period,
                    ),
                    const SizedBox(width: 8),
                    _PeriodChip(
                      label: 'Este Mês',
                      value: ReportPeriod.month,
                      groupValue: period,
                    ),
                    const SizedBox(width: 8),
                    _PeriodChip(
                      label: 'Último Trimestre',
                      value: ReportPeriod.quarter,
                      groupValue: period,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: summaryAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Não foi possível carregar os relatórios.\n$error',
                  ),
                ),
                data: (summary) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        ReportKpiCard(kpi: summary.totalSales),
                        ReportKpiCard(kpi: summary.activeClients),
                        ReportKpiCard(kpi: summary.averageTicket),
                        ReportKpiCard(kpi: summary.goalAchievement),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SalesTrendChart(points: summary.salesTrend),
                    const SizedBox(height: 16),
                    TopProductsChart(products: summary.topProducts),
                    const SizedBox(height: 16),
                    RegionMixChart(regions: summary.regionMix),
                    const SizedBox(height: 16),
                    TopClientsCard(clients: summary.topClients),
                    if (summary.insight != null) ...[
                      const SizedBox(height: 16),
                      SalesInsightCard(
                        insight: summary.insight!,
                        onScheduleVisit: () => context.push('/agenda'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends ConsumerWidget {
  const _PeriodChip({
    required this.label,
    required this.value,
    required this.groupValue,
  });

  final String label;
  final ReportPeriod value;
  final ReportPeriod groupValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => ref.read(reportPeriodProvider.notifier).state = value,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
