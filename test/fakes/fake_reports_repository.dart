import 'package:josapar_representantes/features/reports/domain/entities/reports_summary.dart';
import 'package:josapar_representantes/features/reports/domain/repositories/reports_repository.dart';

class FakeReportsRepository implements ReportsRepository {
  @override
  Future<ReportsSummary> fetchSummary(ReportPeriod period) async {
    return const ReportsSummary(
      totalSales: ReportKpi(
        label: 'VENDAS TOTAIS',
        value: 'R\$ 184.2K',
        growthPercent: 8.5,
      ),
      activeClients: ReportKpi(
        label: 'CLIENTES ATIVOS',
        value: '142',
        growthPercent: 4.2,
      ),
      averageTicket: ReportKpi(
        label: 'TICKET MÉDIO',
        value: 'R\$ 612,00',
        growthPercent: -1.3,
      ),
      goalAchievement: ReportKpi(
        label: 'META ATINGIDA',
        value: '92.4%',
        growthPercent: 6.0,
      ),
      salesTrend: [
        SalesTrendPoint(monthLabel: 'Fev', sales: 30000, target: 35000),
        SalesTrendPoint(monthLabel: 'Mar', sales: 34000, target: 35000),
        SalesTrendPoint(monthLabel: 'Abr', sales: 31000, target: 35000),
        SalesTrendPoint(monthLabel: 'Mai', sales: 38000, target: 35000),
        SalesTrendPoint(monthLabel: 'Jun', sales: 40000, target: 35000),
        SalesTrendPoint(monthLabel: 'Jul', sales: 42000, target: 35000),
      ],
      topProducts: [
        TopProduct(name: 'Arroz Branco Tipo 1 5kg', amount: 52000),
        TopProduct(name: 'Feijão Carioca 1kg', amount: 31000),
      ],
      regionMix: [
        RegionMix(label: 'RS', percent: 0.62),
        RegionMix(label: 'SC', percent: 0.25),
        RegionMix(label: 'PR', percent: 0.13),
      ],
      topClients: [
        TopClient(
          name: 'Distribuidora Rio Grande',
          volume: 62000,
          trend: TrendDirection.up,
        ),
        TopClient(
          name: 'Restaurante Central Buffet',
          volume: 28000,
          trend: TrendDirection.down,
        ),
      ],
      insight: SalesInsight(
        message:
            'A Distribuidora Rio Grande aumentou 18% o volume de compras este '
            'mês — considere agendar uma visita para explorar novos produtos.',
      ),
    );
  }
}
