import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/order_summary.dart';
import '../providers/orders_providers.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(filteredOrdersProvider);
    final filter = ref.watch(orderFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.sync_outlined)),
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
                        ref.read(orderSearchQueryProvider.notifier).state =
                            value,
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar por cliente ou pedido...',
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
                          value: OrderFilter.all,
                          groupValue: filter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Pendentes',
                          value: OrderFilter.pending,
                          groupValue: filter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Enviados',
                          value: OrderFilter.sent,
                          groupValue: filter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Rascunhos',
                          value: OrderFilter.draft,
                          groupValue: filter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ordersAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: context.colors.primary),
                ),
                error: (error, _) => Center(
                  child: Text('Não foi possível carregar os pedidos.\n$error'),
                ),
                data: (orders) {
                  final today = orders.where((o) => o.isToday).toList();
                  final history = orders.where((o) => !o.isToday).toList();

                  if (orders.isEmpty) {
                    return const Center(
                      child: Text('Nenhum pedido encontrado.'),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    children: [
                      if (today.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'PEDIDOS DE HOJE',
                          count: today.length,
                        ),
                        const SizedBox(height: 8),
                        for (final order in today) ...[
                          OrderCard(
                            order: order,
                            onPrimaryAction: () =>
                                context.push(AppRoutes.newOrder),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      if (history.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SectionHeader(
                          title: 'HISTÓRICO RECENTE',
                          count: history.length,
                        ),
                        const SizedBox(height: 8),
                        for (final order in history) ...[
                          OrderCard(
                            order: order,
                            onPrimaryAction: () =>
                                context.push(AppRoutes.newOrder),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Exibindo os últimos 30 dias de pedidos. Para períodos maiores, '
                        'utilize o módulo de Relatórios.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textMuted,
                          fontStyle: FontStyle.italic,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.newOrder),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: context.colors.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: context.colors.neutralSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count PEDIDOS',
            style: TextStyle(
              fontSize: 10,
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ],
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
  final OrderFilter value;
  final OrderFilter groupValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => ref.read(orderFilterProvider.notifier).state = value,
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
