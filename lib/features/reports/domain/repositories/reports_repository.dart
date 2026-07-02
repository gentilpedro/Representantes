import '../entities/reports_summary.dart';

/// Contrato de relatórios. A implementação real deve consumir a Web API
/// .NET 10 (ex: `GET /api/reports/summary?period=...`).
abstract class ReportsRepository {
  Future<ReportsSummary> fetchSummary(ReportPeriod period);
}
