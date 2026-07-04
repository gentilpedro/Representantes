import 'package:josapar_representantes/features/orders/domain/entities/order_summary.dart';
import 'package:josapar_representantes/features/orders/domain/repositories/orders_repository.dart';
import 'package:josapar_representantes/features/sync/domain/entities/sync_summary.dart';
import 'package:josapar_representantes/features/sync/domain/repositories/sync_repository.dart';

/// Espelha o `/api/sync/summary` real: `successCount` é derivado dos
/// pedidos `sent` (via [ordersRepository], a mesma fonte que o
/// `SyncController` usa) — sem fila/histórico fictício. `conflict` é
/// opcional só pra exercitar a renderização condicional da tela.
class FakeSyncRepository implements SyncRepository {
  FakeSyncRepository({
    required this.ordersRepository,
    this.conflict,
    this.baseSuccessCount = 0,
  });

  final OrdersRepository ordersRepository;
  final SyncConflict? conflict;
  final int baseSuccessCount;

  @override
  Future<SyncSummary> fetchSummary() async {
    final orders = await ordersRepository.fetchOrders();
    final sentCount = orders.where((o) => o.status == OrderStatus.sent).length;

    return SyncSummary(
      isConnected: true,
      lastUpdateLabel: 'Hoje, 14:32',
      pendingCount: 0,
      successCount: baseSuccessCount + sentCount,
      queue: const [],
      history: const [],
      conflict: conflict,
    );
  }

  @override
  Future<SyncSummary> syncNow() => fetchSummary();
}
