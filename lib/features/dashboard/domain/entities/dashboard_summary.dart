enum RecentOrderStatus { synced, pending, draft }

class RecentOrderSummary {
  const RecentOrderSummary({
    required this.code,
    required this.clientName,
    required this.amount,
    required this.timeLabel,
    required this.status,
  });

  final String code;
  final String clientName;
  final double amount;
  final String timeLabel;
  final RecentOrderStatus status;
}

class MonthlySalesPoint {
  const MonthlySalesPoint({required this.monthLabel, required this.amount});

  final String monthLabel;
  final double amount;
}

class DashboardSummary {
  const DashboardSummary({
    required this.greetingName,
    required this.scheduledVisitsToday,
    required this.salesToday,
    required this.salesTodayGrowthPercent,
    required this.visitsCompleted,
    required this.visitsTotal,
    required this.monthlyGoalAchieved,
    required this.monthlyGoalTarget,
    required this.monthlyGoalPercent,
    required this.monthlySeries,
    required this.recentOrders,
  });

  final String greetingName;
  final int scheduledVisitsToday;
  final double salesToday;
  final double salesTodayGrowthPercent;
  final int visitsCompleted;
  final int visitsTotal;
  final double monthlyGoalAchieved;
  final double monthlyGoalTarget;
  final double monthlyGoalPercent;
  final List<MonthlySalesPoint> monthlySeries;
  final List<RecentOrderSummary> recentOrders;
}
