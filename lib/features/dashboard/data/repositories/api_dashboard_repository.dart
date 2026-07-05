import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/dashboard_exception.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Implementação real de [DashboardRepository], contra
/// `GET /api/dashboard/summary` da Web API .NET 10.
class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DashboardSummary> fetchSummary() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/dashboard/summary',
      );
      return _parseSummary(response.data!);
    } on DioException catch (_) {
      throw DashboardException(
        'Não foi possível carregar o dashboard. Tente novamente.',
      );
    }
  }

  DashboardSummary _parseSummary(Map<String, dynamic> json) {
    return DashboardSummary(
      greetingName: json['greetingName'] as String,
      scheduledVisitsToday: json['scheduledVisitsToday'] as int,
      salesToday: (json['salesToday'] as num).toDouble(),
      salesTodayGrowthPercent: (json['salesTodayGrowthPercent'] as num)
          .toDouble(),
      visitsCompleted: json['visitsCompleted'] as int,
      visitsTotal: json['visitsTotal'] as int,
      monthlyGoalAchieved: (json['monthlyGoalAchieved'] as num).toDouble(),
      monthlyGoalTarget: (json['monthlyGoalTarget'] as num).toDouble(),
      monthlyGoalPercent: (json['monthlyGoalPercent'] as num).toDouble(),
      monthlySeries: (json['monthlySeries'] as List<dynamic>)
          .map((v) => _parseMonthlyPoint(v as Map<String, dynamic>))
          .toList(),
      recentOrders: (json['recentOrders'] as List<dynamic>)
          .map((v) => _parseRecentOrder(v as Map<String, dynamic>))
          .toList(),
    );
  }

  MonthlySalesPoint _parseMonthlyPoint(Map<String, dynamic> json) {
    return MonthlySalesPoint(
      monthLabel: json['monthLabel'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  RecentOrderSummary _parseRecentOrder(Map<String, dynamic> json) {
    final createdAtLocal = DateTime.parse(
      json['createdAtUtc'] as String,
    ).toLocal();

    return RecentOrderSummary(
      code: json['code'] as String,
      clientName: json['clientName'] as String,
      amount: (json['amount'] as num).toDouble(),
      timeLabel: AppFormatters.timeOfDay(createdAtLocal),
      status: _recentStatusFromJson(json['status'] as String),
    );
  }

  /// `RecentOrderStatus` só tem 3 valores (synced/pending/draft) — o
  /// `OrderStatus` real do servidor tem 4 (inclui `error`), que aqui cai
  /// como "pending" (ainda precisa de atenção/reenvio).
  RecentOrderStatus _recentStatusFromJson(String value) {
    switch (value) {
      case 'sent':
        return RecentOrderStatus.synced;
      case 'draft':
        return RecentOrderStatus.draft;
      case 'pending':
      case 'error':
      default:
        return RecentOrderStatus.pending;
    }
  }
}
