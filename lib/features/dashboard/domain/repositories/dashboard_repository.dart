import '../entities/dashboard_summary.dart';

/// Contrato do dashboard. A implementação real deve consumir algo como
/// `GET /api/dashboard/summary` na Web API .NET 10.
abstract class DashboardRepository {
  Future<DashboardSummary> fetchSummary();
}
