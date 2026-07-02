enum ReportPeriod { today, week, month, quarter }

enum TrendDirection { up, down }

class ReportKpi {
  const ReportKpi({
    required this.label,
    required this.value,
    required this.growthPercent,
  });

  final String label;
  final String value;
  final double growthPercent;
}

class SalesTrendPoint {
  const SalesTrendPoint({
    required this.monthLabel,
    required this.sales,
    required this.target,
  });

  final String monthLabel;
  final double sales;
  final double target;
}

class TopProduct {
  const TopProduct({required this.name, required this.amount});

  final String name;
  final double amount;
}

class RegionMix {
  const RegionMix({required this.label, required this.percent});

  final String label;
  final double percent;
}

class TopClient {
  const TopClient({
    required this.name,
    required this.volume,
    required this.trend,
  });

  final String name;
  final double volume;
  final TrendDirection trend;
}

class SalesInsight {
  const SalesInsight({required this.message});

  final String message;
}

class ReportsSummary {
  const ReportsSummary({
    required this.totalSales,
    required this.activeClients,
    required this.averageTicket,
    required this.goalAchievement,
    required this.salesTrend,
    required this.topProducts,
    required this.regionMix,
    required this.topClients,
    this.insight,
  });

  final ReportKpi totalSales;
  final ReportKpi activeClients;
  final ReportKpi averageTicket;
  final ReportKpi goalAchievement;
  final List<SalesTrendPoint> salesTrend;
  final List<TopProduct> topProducts;
  final List<RegionMix> regionMix;
  final List<TopClient> topClients;
  final SalesInsight? insight;
}
