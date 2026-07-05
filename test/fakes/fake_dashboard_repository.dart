import 'package:josapar_representantes/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:josapar_representantes/features/dashboard/domain/repositories/dashboard_repository.dart';

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> fetchSummary() async {
    return const DashboardSummary(
      greetingName: 'Ricardo Santos',
      scheduledVisitsToday: 5,
      salesToday: 1250.40,
      salesTodayGrowthPercent: 12,
      visitsCompleted: 2,
      visitsTotal: 5,
      monthlyGoalAchieved: 42000,
      monthlyGoalTarget: 60000,
      monthlyGoalPercent: 0.7,
      monthlySeries: [
        MonthlySalesPoint(monthLabel: 'Fev', amount: 30000),
        MonthlySalesPoint(monthLabel: 'Mar', amount: 34000),
        MonthlySalesPoint(monthLabel: 'Abr', amount: 31000),
        MonthlySalesPoint(monthLabel: 'Mai', amount: 38000),
        MonthlySalesPoint(monthLabel: 'Jun', amount: 40000),
        MonthlySalesPoint(monthLabel: 'Jul', amount: 42000),
      ],
      recentOrders: [
        RecentOrderSummary(
          code: '#PED-9082',
          clientName: 'Distribuidora Rio Grande',
          amount: 452.30,
          timeLabel: '10:45',
          status: RecentOrderStatus.synced,
        ),
        RecentOrderSummary(
          code: '#PED-8940',
          clientName: 'Restaurante Central Buffet',
          amount: 812.10,
          timeLabel: 'Ontem',
          status: RecentOrderStatus.pending,
        ),
      ],
    );
  }
}
