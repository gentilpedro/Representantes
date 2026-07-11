import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../providers/new_order_providers.dart';
import '../providers/orders_providers.dart';
import '../widgets/cart_item_tile.dart';

enum _ExitChoice { discard, saveDraft }

class NewOrderScreen extends ConsumerWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(newOrderControllerProvider);
    final controller = ref.read(newOrderControllerProvider.notifier);
    final client = orderState.client;

    return PopScope(
      // Só intercepta o "voltar" (gesto do sistema, seta da AppBar) quando
      // há itens no carrinho — sem isso, sair perde o pedido em construção
      // silenciosamente.
      canPop: orderState.items.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit(context, ref, controller, orderState);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Novo Pedido'),
          actions: [
            IconButton(
              onPressed: orderState.items.isEmpty
                  ? null
                  : () => _saveDraft(context, ref, controller, orderState),
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Salvar rascunho',
            ),
          ],
        ),
        body: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CLIENTE SELECIONADO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textMuted,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.selectClient),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Alterar'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (client != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.colors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.apartment_outlined,
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'CNPJ: ${client.cnpj}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _MiniTag(label: 'Cód: ${client.code}'),
                                  _MiniTag(
                                    label:
                                        'Limite: ${AppFormatters.currency(client.creditLimit)}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ITENS NO CARRINHO (${orderState.items.length})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textMuted,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.catalog, extra: true),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: orderState.items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Nenhum item adicionado ainda.',
                              style: TextStyle(color: context.colors.textMuted),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (
                              var i = 0;
                              i < orderState.items.length;
                              i++
                            ) ...[
                              CartItemTile(
                                item: orderState.items[i],
                                onQuantityChanged: (qty) =>
                                    controller.updateQuantity(
                                      orderState.items[i].productId,
                                      qty,
                                    ),
                                onDiscountChanged: (pct) =>
                                    controller.updateDiscount(
                                      orderState.items[i].productId,
                                      pct,
                                    ),
                                onRemove: () => controller.removeItem(
                                  orderState.items[i].productId,
                                ),
                              ),
                              if (i != orderState.items.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'OBSERVAÇÕES DO PEDIDO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                maxLines: 3,
                onChanged: controller.updateNotes,
                decoration: const InputDecoration(
                  hintText:
                      'Ex: Entrega somente após as 14h, embalagem reforçada...',
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 16,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Resumo da Negociação',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SummaryLine(
                        label: 'Subtotal Bruto',
                        value: AppFormatters.currency(orderState.subtotal),
                      ),
                      _SummaryLine(
                        label: 'Descontos Aplicados',
                        value:
                            '- ${AppFormatters.currency(orderState.discounts)}',
                      ),
                      _SummaryLine(
                        label: 'Impostos Estimados',
                        value: AppFormatters.currency(
                          orderState.estimatedTaxes,
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL LÍQUIDO',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                AppFormatters.currency(orderState.total),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: context.colors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.neutralSoft,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '30/60 DIAS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Faturamento Direto',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.infoSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Este pedido será salvo localmente e sincronizado assim que houver conexão estável.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ResponsiveContent(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _confirmExit(context, ref, controller, orderState),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: orderState.items.isEmpty
                          ? null
                          : () => _finalizeOrder(
                              context,
                              ref,
                              controller,
                              orderState,
                            ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Finalizar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmExit(
  BuildContext context,
  WidgetRef ref,
  NewOrderController controller,
  NewOrderState orderState,
) async {
  if (orderState.items.isEmpty) {
    context.pop();
    return;
  }

  final choice = await showDialog<_ExitChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sair do pedido?'),
      content: const Text(
        'Há itens no carrinho. Descarte o pedido ou salve como rascunho '
        'para continuar depois.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Continuar editando'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(_ExitChoice.discard),
          child: const Text('Descartar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_ExitChoice.saveDraft),
          child: const Text('Salvar rascunho'),
        ),
      ],
    ),
  );

  if (!context.mounted || choice == null) return;

  if (choice == _ExitChoice.discard) {
    controller.clear();
    if (context.mounted) context.pop();
    return;
  }

  await _saveDraft(context, ref, controller, orderState);
}

Future<void> _saveDraft(
  BuildContext context,
  WidgetRef ref,
  NewOrderController controller,
  NewOrderState orderState,
) async {
  final client = orderState.client;
  if (client == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecione um cliente antes de salvar.')),
    );
    return;
  }
  await ref
      .read(ordersRepositoryProvider)
      .createOrder(
        clientId: client.id,
        clientName: client.name,
        items: orderState.items,
        notes: orderState.notes,
        isDraft: true,
      );
  controller.clear();
  ref.invalidate(ordersListProvider);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Rascunho salvo. Rascunhos não entram na fila de sincronização.',
      ),
    ),
  );
  context.pop();
}

Future<void> _finalizeOrder(
  BuildContext context,
  WidgetRef ref,
  NewOrderController controller,
  NewOrderState orderState,
) async {
  final client = orderState.client;
  if (client == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecione um cliente antes de finalizar.')),
    );
    return;
  }
  await ref
      .read(ordersRepositoryProvider)
      .createOrder(
        clientId: client.id,
        clientName: client.name,
        items: orderState.items,
        notes: orderState.notes,
        isDraft: false,
      );
  controller.clear();
  ref.invalidate(ordersListProvider);

  final isOnline = await ref.read(connectivityServiceProvider).isOnline();
  if (isOnline) {
    await ref.read(syncControllerProvider.notifier).syncNow();
  } else {
    ref.invalidate(syncControllerProvider);
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isOnline
            ? 'Pedido enviado para sincronização.'
            : 'Pedido salvo localmente. Será sincronizado automaticamente quando a conexão voltar.',
      ),
    ),
  );
  context.pop();
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.colors.neutralSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
