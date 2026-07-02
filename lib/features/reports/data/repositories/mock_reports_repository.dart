import '../../domain/entities/reports_summary.dart';
import '../../domain/repositories/reports_repository.dart';

/// Dados fixos espelhando a tela "Relatórios & Indicadores" do protótipo
/// (recorte "Este Mês"). Os demais períodos devolvem o mesmo conjunto de
/// dados por enquanto — a implementação real buscaria cada recorte na API.
class MockReportsRepository implements ReportsRepository {
  @override
  Future<ReportsSummary> fetchSummary(ReportPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const ReportsSummary(
      totalSales: ReportKpi(
        label: 'VENDAS TOTAIS',
        value: 'R\$ 184.2K',
        growthPercent: 12.5,
      ),
      activeClients: ReportKpi(
        label: 'CLIENTES ATIVOS',
        value: '142',
        growthPercent: 3.2,
      ),
      averageTicket: ReportKpi(
        label: 'TICKET MÉDIO',
        value: 'R\$ 1.298',
        growthPercent: -1.8,
      ),
      goalAchievement: ReportKpi(
        label: 'ATING. META',
        value: '92.4%',
        growthPercent: 5.1,
      ),
      salesTrend: [
        SalesTrendPoint(monthLabel: 'Jan', sales: 4200, target: 4000),
        SalesTrendPoint(monthLabel: 'Fev', sales: 4600, target: 4200),
        SalesTrendPoint(monthLabel: 'Mar', sales: 4100, target: 4300),
        SalesTrendPoint(monthLabel: 'Abr', sales: 6100, target: 4800),
        SalesTrendPoint(monthLabel: 'Mai', sales: 5700, target: 5600),
        SalesTrendPoint(monthLabel: 'Jun', sales: 6300, target: 5800),
      ],
      topProducts: [
        TopProduct(name: 'Arroz Tio João', amount: 68000),
        TopProduct(name: 'Arroz Meu Biju', amount: 52000),
        TopProduct(name: 'Feijão Tio João', amount: 34000),
        TopProduct(name: 'Azeite Nova Oliva', amount: 21000),
      ],
      regionMix: [
        RegionMix(label: 'Sul', percent: 0.45),
        RegionMix(label: 'Sudeste', percent: 0.30),
        RegionMix(label: 'Nordeste', percent: 0.15),
        RegionMix(label: 'Outros', percent: 0.10),
      ],
      topClients: [
        TopClient(
          name: 'Supermercado Alvorada',
          volume: 45200,
          trend: TrendDirection.up,
        ),
        TopClient(
          name: 'Distribuidora Sul Ltda',
          volume: 38150,
          trend: TrendDirection.up,
        ),
        TopClient(
          name: 'Mercearia do Zé',
          volume: 12400,
          trend: TrendDirection.down,
        ),
      ],
      insight: SalesInsight(
        message:
            'O cliente Mercearia do Zé reduziu as compras em 12% este mês. '
            'Recomendamos uma visita prioritária para reativação de estoque de arroz.',
      ),
    );
  }
}
