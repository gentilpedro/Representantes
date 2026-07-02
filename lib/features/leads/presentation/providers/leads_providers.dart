import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/mock_leads_repository.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/leads_repository.dart';

final leadsRepositoryProvider = Provider<LeadsRepository>(
  (ref) => MockLeadsRepository(ref.watch(leadsCacheBoxProvider)),
);

final leadsListProvider = FutureProvider.autoDispose<List<Lead>>((ref) {
  return ref.watch(leadsRepositoryProvider).fetchLeads();
});
