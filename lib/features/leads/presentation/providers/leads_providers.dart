import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/api_leads_repository.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/leads_repository.dart';

final leadsRepositoryProvider = Provider<LeadsRepository>(
  (ref) => ApiLeadsRepository(
    ref.watch(apiClientProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(pendingActionsQueueProvider),
  ),
);

final leadsListProvider = FutureProvider.autoDispose<List<Lead>>((ref) {
  return ref.watch(leadsRepositoryProvider).fetchLeads();
});

final leadDetailProvider = FutureProvider.autoDispose.family<Lead, String>((
  ref,
  id,
) {
  return ref.watch(leadsRepositoryProvider).fetchLead(id);
});

final leadSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// `null` = "Todos".
final leadStatusFilterProvider = StateProvider.autoDispose<LeadStatus?>(
  (ref) => null,
);

final filteredLeadsProvider = Provider.autoDispose<AsyncValue<List<Lead>>>((
  ref,
) {
  final leadsAsync = ref.watch(leadsListProvider);
  final query = ref.watch(leadSearchQueryProvider).trim().toLowerCase();
  final statusFilter = ref.watch(leadStatusFilterProvider);

  return leadsAsync.whenData((leads) {
    return leads.where((lead) {
      final matchesQuery =
          query.isEmpty ||
          lead.contactName.toLowerCase().contains(query) ||
          lead.companyName.toLowerCase().contains(query);
      final matchesStatus = statusFilter == null || lead.status == statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  });
});
