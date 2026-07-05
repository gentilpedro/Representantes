import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/api_clients_repository.dart';
import '../../domain/entities/client_detail.dart';
import '../../domain/entities/client_list_item.dart';
import '../../domain/repositories/clients_repository.dart';

enum ClientFilter { all, favorites, blocked, offline }

final clientsRepositoryProvider = Provider<ClientsRepository>(
  (ref) => ApiClientsRepository(ref.watch(apiClientProvider)),
);

final clientsListProvider = FutureProvider.autoDispose<List<ClientListItem>>((
  ref,
) {
  return ref.watch(clientsRepositoryProvider).fetchClients();
});

final clientDetailProvider = FutureProvider.autoDispose
    .family<ClientDetail, String>((ref, clientId) {
      return ref.watch(clientsRepositoryProvider).fetchClientDetail(clientId);
    });

final clientSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final clientFilterProvider = StateProvider.autoDispose<ClientFilter>(
  (ref) => ClientFilter.all,
);

final filteredClientsProvider =
    Provider.autoDispose<AsyncValue<List<ClientListItem>>>((ref) {
      final clientsAsync = ref.watch(clientsListProvider);
      final query = ref.watch(clientSearchQueryProvider).trim().toLowerCase();
      final filter = ref.watch(clientFilterProvider);

      return clientsAsync.whenData((clients) {
        return clients.where((client) {
          final matchesQuery =
              query.isEmpty ||
              client.name.toLowerCase().contains(query) ||
              client.cnpj.contains(query) ||
              client.code.contains(query);

          final matchesFilter = switch (filter) {
            ClientFilter.all => true,
            ClientFilter.favorites => client.isFavorite,
            ClientFilter.blocked => client.isBlocked,
            ClientFilter.offline => client.isOffline,
          };

          return matchesQuery && matchesFilter;
        }).toList();
      });
    });
