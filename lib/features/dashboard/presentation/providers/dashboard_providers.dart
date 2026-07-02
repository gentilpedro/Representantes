import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_dashboard_repository.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return MockDashboardRepository();
});

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((
  ref,
) {
  return ref.watch(dashboardRepositoryProvider).fetchSummary();
});
