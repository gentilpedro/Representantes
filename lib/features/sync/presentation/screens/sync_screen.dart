import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/sync_summary.dart';
import '../providers/sync_providers.dart';
import '../widgets/sync_queue_tile.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(syncControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(syncControllerProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ResponsiveContent(
        child: summaryAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: context.colors.primary),
          ),
          error: (error, _) => Center(
            child: Text('Não foi possível carregar a sincronização.\n$error'),
          ),
          data: (summary) =>
              _buildContent(context, ref, summary, summaryAsync.isLoading),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SyncSummary summary,
    bool isSyncing,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Central de Dados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          summary.isConnected ? Icons.wifi : Icons.wifi_off,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          summary.isConnected ? 'Conectado' : 'Offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Última atualização: ${summary.lastUpdateLabel}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _StatBlock(
                    icon: Icons.access_time,
                    value: '${summary.pendingCount}'.padLeft(2, '0'),
                    label: 'PENDENTES',
                  ),
                  const SizedBox(width: 10),
                  _StatBlock(
                    icon: Icons.check_circle_outline,
                    value: '${summary.successCount}'.padLeft(2, '0'),
                    label: 'SUCESSO',
                  ),
                  const SizedBox(width: 10),
                  _StatBlock(
                    icon: Icons.error_outline,
                    value: '${summary.conflictCount}'.padLeft(2, '0'),
                    label: 'CONFLITOS',
                    isAlert: summary.conflictCount > 0,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progresso da Fila',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isSyncing ? 'Sincronizando...' : 'Aguardando',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LinearProgressIndicator(
                  value: isSyncing
                      ? null
                      : (summary.pendingCount == 0 ? 1 : 0.05),
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSyncing
                      ? null
                      : () =>
                            ref.read(syncControllerProvider.notifier).syncNow(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: context.colors.primary,
                  ),
                  icon: isSyncing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.primary,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    isSyncing ? 'Sincronizando...' : 'Sincronizar Agora',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (summary.conflict != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.errorSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error, color: context.colors.error, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Conflito Detectado',
                      style: TextStyle(
                        color: context.colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Pedido ${summary.conflict!.orderCode} (${summary.conflict!.clientName}) falhou: ${summary.conflict!.reason}',
                  style: TextStyle(
                    color: context.colors.error,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Resolução de conflitos ainda não implementada.',
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.error,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Resolver Agora'),
                      Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_outlined,
                  size: 15,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'FILA DE TRANSMISSÃO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.colors.neutralSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${summary.queue.length} ITENS',
                style: TextStyle(
                  fontSize: 10,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (summary.queue.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Fila vazia. Tudo sincronizado!',
                style: TextStyle(color: context.colors.textMuted),
              ),
            ),
          )
        else
          for (final item in summary.queue) ...[
            SyncQueueTile(item: item),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.history, size: 15, color: context.colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'HISTÓRICO DE SINCRONIA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final entry in summary.history) ...[
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Card(
              child: ExpansionTile(
                title: Text(
                  entry.dateLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  entry.summary,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textMuted,
                  ),
                ),
                leading: Icon(
                  Icons.check_circle_outline,
                  color: context.colors.success,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        entry.summary,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.value,
    required this.label,
    this.isAlert = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: isAlert ? Colors.redAccent[100] : Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
