import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../orders/domain/entities/order_summary.dart';
import '../../../orders/presentation/providers/orders_providers.dart';
import '../../data/repositories/mock_sync_repository.dart';
import '../../domain/entities/sync_summary.dart';
import '../../domain/repositories/sync_repository.dart';

final syncRepositoryProvider = Provider<SyncRepository>(
  (ref) => MockSyncRepository(),
);

/// Orquestra a fila de sincronização combinando os pedidos `pending` de
/// verdade (vindos de `OrdersRepository`) com os itens de demonstração do
/// `SyncRepository` (cadastros/check-ins). Também observa
/// `connectivityStatusProvider` e dispara `syncNow()` sozinho assim que o
/// dispositivo volta a ficar online — pedidos `draft` nunca entram nessa
/// fila, então nunca são sincronizados automaticamente.
class SyncController extends AsyncNotifier<SyncSummary> {
  @override
  Future<SyncSummary> build() async {
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (previous, next) {
      final wasOffline = previous != null && previous.valueOrNull == false;
      final isOnlineNow = next.valueOrNull == true;
      if (wasOffline && isOnlineNow) {
        syncNow();
      }
    });
    return _composeSummary();
  }

  Future<SyncSummary> _composeSummary() async {
    final base = await ref.watch(syncRepositoryProvider).fetchSummary();
    final orders = await ref.watch(ordersRepositoryProvider).fetchOrders();
    final isOnline = await ref.watch(connectivityServiceProvider).isOnline();

    final orderQueueItems = orders
        .where((order) => order.status == OrderStatus.pending)
        .map(
          (order) => SyncQueueItem(
            id: 'order-${order.id}',
            title: 'Pedido ${order.code}',
            subtitle: order.clientName,
            tag: AppFormatters.currency(order.total),
            status: isOnline
                ? QueueItemStatus.pending
                : QueueItemStatus.offline,
            timeLabel: order.dateLabel,
          ),
        )
        .toList();

    final queue = [...orderQueueItems, ...base.queue];

    return SyncSummary(
      isConnected: isOnline,
      lastUpdateLabel: base.lastUpdateLabel,
      pendingCount: queue.length,
      successCount: base.successCount,
      conflict: base.conflict,
      queue: queue,
      history: base.history,
    );
  }

  /// Envia toda a fila pendente (pedidos + itens de demonstração). Pode ser
  /// disparado manualmente ("Sincronizar Agora") ou automaticamente pelo
  /// listener de conectividade em [build].
  Future<void> syncNow() async {
    if (state.isLoading) return;
    state = const AsyncLoading<SyncSummary>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final syncedOrders = await ref
          .read(ordersRepositoryProvider)
          .syncPendingOrders();
      final base = await ref.read(syncRepositoryProvider).syncNow();
      // Só invalida se a tela de Pedidos estiver de fato montada e
      // observando — invalidar um provider `autoDispose` nunca lido cria e
      // descarta o elemento na hora, mas o `Future.delayed` interno
      // continua rodando "solto" em segundo plano.
      if (ref.exists(ordersListProvider)) {
        ref.invalidate(ordersListProvider);
      }
      return SyncSummary(
        isConnected: true,
        lastUpdateLabel: base.lastUpdateLabel,
        pendingCount: base.queue.length,
        successCount: base.successCount + syncedOrders,
        conflict: base.conflict,
        queue: base.queue,
        history: base.history,
      );
    });
  }
}

final syncControllerProvider =
    AsyncNotifierProvider<SyncController, SyncSummary>(SyncController.new);
