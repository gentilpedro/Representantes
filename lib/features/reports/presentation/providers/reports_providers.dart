import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/api_reports_repository.dart';
import '../../domain/entities/reports_summary.dart';
import '../../domain/repositories/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>(
  (ref) => ApiReportsRepository(ref.watch(apiClientProvider)),
);

final reportPeriodProvider = StateProvider.autoDispose<ReportPeriod>(
  (ref) => ReportPeriod.month,
);

final reportsSummaryProvider = FutureProvider.autoDispose<ReportsSummary>((
  ref,
) {
  final period = ref.watch(reportPeriodProvider);
  return ref.watch(reportsRepositoryProvider).fetchSummary(period);
});
