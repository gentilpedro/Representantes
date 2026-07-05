import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/client_detail.dart';
import '../providers/clients_providers.dart';
import '../widgets/client_tier_chip.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(clientDetailProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detailAsync.valueOrNull?.name ?? 'Cliente',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline)),
        ],
      ),
      body: ResponsiveContent(
        child: detailAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: context.colors.primary),
          ),
          error: (error, _) => Center(
            child: Text('Não foi possível carregar o cliente.\n$error'),
          ),
          data: (detail) => _buildContent(context, detail),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.newOrder),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientDetail detail) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: context.colors.neutralSoft,
              child: Text(
                detail.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          detail.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClientTierChip(tier: detail.tier),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${detail.code} • ${detail.cnpj}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _ContactButton(icon: Icons.call_outlined),
            const SizedBox(width: 10),
            _ContactButton(icon: Icons.phone_iphone_outlined),
            const SizedBox(width: 10),
            _ContactButton(icon: Icons.mail_outline),
          ],
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
                    Icon(Icons.credit_card, size: 16, color: context.colors.primary),
                    const SizedBox(width: 6),
                    const Text(
                      'Resumo Financeiro',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Limite Utilizado',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(detail.creditUsedPercent * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: LinearProgressIndicator(
                    value: detail.creditUsedPercent.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: context.colors.neutralSoft,
                    valueColor: AlwaysStoppedAnimation(context.colors.primary),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _AmountBlock(
                        label: 'DISPONÍVEL',
                        value: AppFormatters.currency(detail.creditAvailable),
                      ),
                    ),
                    Expanded(
                      child: _AmountBlock(
                        label: 'TOTAL LIMITE',
                        value: AppFormatters.currency(detail.creditLimit),
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                if (detail.pendingInvoice != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.errorSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: context.colors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1 Fatura Vencendo',
                                style: TextStyle(
                                  color: context.colors.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Vence em ${detail.pendingInvoice!.dueDateLabel} - ${AppFormatters.currency(detail.pendingInvoice!.amount)}',
                                style: TextStyle(
                                  color: context.colors.error,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ENDEREÇO DE ENTREGA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.colors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${detail.deliveryAddress.street}, ${detail.deliveryAddress.district}, '
                    '${detail.deliveryAddress.city} - ${detail.deliveryAddress.state}',
                    style: const TextStyle(fontSize: 12, height: 1.3),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Rota'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Row(
                children: [
                  Icon(Icons.history, size: 16, color: context.colors.textSecondary),
                  const SizedBox(width: 8),
                  const Text(
                    'Histórico de Pedidos',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.orderHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nenhum pedido registrado ainda.',
                      style: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  )
                else ...[
                  for (final order in detail.orderHistory)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pedido ${order.code}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  order.dateLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppFormatters.currency(order.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.successSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.colors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Ver histórico completo'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'OBSERVAÇÕES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.colors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: context.colors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    detail.notes?.isNotEmpty == true
                        ? detail.notes!
                        : 'Nenhuma observação registrada.',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          minimumSize: const Size(0, 44),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: context.colors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ],
    );
  }
}
