import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/client_summary.dart';
import '../providers/clients_providers.dart';
import '../widgets/client_card.dart';

/// Quando [pickMode] é true, a tela funciona como um seletor: tocar num
/// cliente chama [onClientPicked] com o cliente escolhido e volta para a
/// tela anterior, em vez de abrir o Detalhe do Cliente. Cada fluxo que usa
/// o seletor (Novo Pedido, Nova Visita...) passa seu próprio callback.
class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key, this.pickMode = false, this.onClientPicked});

  final bool pickMode;
  final ValueChanged<ClientSummary>? onClientPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(filteredClientsProvider);
    final filter = ref.watch(clientFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(pickMode ? 'Selecionar Cliente' : 'Clientes'),
        actions: pickMode
            ? null
            : [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.sync_outlined),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.notifications),
                  icon: const Icon(Icons.notifications_outlined),
                ),
              ],
      ),
      body: ResponsiveContent(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) =>
                        ref.read(clientSearchQueryProvider.notifier).state =
                            value,
                    decoration: const InputDecoration(
                      hintText: 'Nome, CNPJ ou Código...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Todos',
                          value: ClientFilter.all,
                          groupValue: filter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Favoritos',
                          value: ClientFilter.favorites,
                          groupValue: filter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Bloqueados',
                          value: ClientFilter.blocked,
                          groupValue: filter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Offline',
                          value: ClientFilter.offline,
                          groupValue: filter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: clientsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: context.colors.primary),
                ),
                error: (error, _) => Center(
                  child: Text('Não foi possível carregar os clientes.\n$error'),
                ),
                data: (clients) {
                  if (clients.isEmpty) {
                    return const Center(
                      child: Text('Nenhum cliente encontrado.'),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Exibindo ${clients.length} clientes',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (final client in clients) ...[
                        ClientCard(
                          client: client,
                          onTap: pickMode
                              ? () {
                                  onClientPicked?.call(client.toSummary());
                                  context.pop();
                                }
                              : () => context.push(
                                  AppRoutes.clientDetail(client.id),
                                ),
                          onToggleFavorite: () {
                            ref
                                .read(clientsRepositoryProvider)
                                .toggleFavorite(client.id, !client.isFavorite)
                                .then((_) {
                                  ref.invalidate(clientsListProvider);
                                });
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Fim da lista. Use a busca para encontrar outros clientes na base.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: pickMode
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(AppRoutes.newClient),
              child: const Icon(Icons.person_add_alt_1_outlined),
            ),
    );
  }
}

class _FilterChip extends ConsumerWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.groupValue,
  });

  final String label;
  final ClientFilter value;
  final ClientFilter groupValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => ref.read(clientFilterProvider.notifier).state = value,
      selectedColor: context.colors.primary,
      backgroundColor: context.colors.surface,
      side: BorderSide(color: context.colors.border),
      labelStyle: TextStyle(
        color: selected ? Colors.white : context.colors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
