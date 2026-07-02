import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Dados fixos espelhando a tela "Início" do protótipo, usados enquanto a
/// Web API .NET 10 não está disponível.
class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> fetchSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const DashboardSummary(
      greetingName: 'Ricardo',
      scheduledVisitsToday: 4,
      salesToday: 12450,
      salesTodayGrowthPercent: 12,
      visitsCompleted: 3,
      visitsTotal: 8,
      monthlyGoalAchieved: 185400,
      monthlyGoalTarget: 225000,
      monthlyGoalPercent: 0.82,
      monthlySeries: [
        MonthlySalesPoint(monthLabel: 'Jan', amount: 47000),
        MonthlySalesPoint(monthLabel: 'Fev', amount: 52000),
        MonthlySalesPoint(monthLabel: 'Mar', amount: 46000),
        MonthlySalesPoint(monthLabel: 'Abr', amount: 61000),
        MonthlySalesPoint(monthLabel: 'Mai', amount: 49500),
        MonthlySalesPoint(monthLabel: 'Jun', amount: 63500),
      ],
      recentOrders: [
        RecentOrderSummary(
          code: '#PED-9982',
          clientName: 'Supermercado Oliveira Ltda',
          amount: 4580,
          timeLabel: '14:20',
          status: RecentOrderStatus.synced,
        ),
        RecentOrderSummary(
          code: '#PED-9981',
          clientName: 'Mercearia do Bairro',
          amount: 1240.50,
          timeLabel: '11:45',
          status: RecentOrderStatus.pending,
        ),
        RecentOrderSummary(
          code: '#PED-9980',
          clientName: 'Restaurante Central S.A.',
          amount: 890,
          timeLabel: 'Ontem',
          status: RecentOrderStatus.draft,
        ),
      ],
    );
  }
}
