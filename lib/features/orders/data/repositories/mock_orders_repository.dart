import 'dart:async';

import 'package:hive/hive.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/repositories/orders_repository.dart';
import '../local/offline_order_record.dart';

/// Dados em memória espelhando a tela "Meus Pedidos" do protótipo, com uma
/// exceção: pedidos `pending` (feitos offline, aguardando sincronização) são
/// também gravados na box Hive `pending_orders`, e restaurados dali quando o
/// app reabre — é a fila de pedidos que precisa sobreviver a um restart ou
/// refresh da página. Assim que um pedido é sincronizado com sucesso, seu
/// registro é apagado da box (ver [syncPendingOrders]); o restante do
/// histórico (enviados/erro/rascunho) continua sendo só dado de exemplo, já
/// que ainda não existe uma Web API real para guardar isso de verdade.
class MockOrdersRepository implements OrdersRepository {
  MockOrdersRepository(this._pendingOrdersBox) {
    _restorePendingFromBox();
  }

  final Box<OfflineOrderRecord> _pendingOrdersBox;

  final List<OrderSummary> _orders = [
    const OrderSummary(
      id: '9082',
      code: '#PED-9082',
      clientName: 'Supermercado Silva & Filhos Ltda',
      dateLabel: 'Hoje, 10:45',
      itemsCount: 12,
      total: 4520.50,
      status: OrderStatus.pending,
      isToday: true,
    ),
    const OrderSummary(
      id: '9078',
      code: '#PED-9078',
      clientName: 'Panificadora Delícia de Gramado',
      dateLabel: 'Hoje, 08:30',
      itemsCount: 5,
      total: 1240.00,
      status: OrderStatus.sent,
      isToday: true,
    ),
    const OrderSummary(
      id: '8992',
      code: '#PED-8992',
      clientName: 'Restaurante Central Buffet',
      dateLabel: 'Ontem',
      itemsCount: 8,
      total: 890.75,
      status: OrderStatus.error,
      isToday: false,
    ),
    const OrderSummary(
      id: '8950',
      code: '#PED-8950',
      clientName: 'Mini Mercado Horizonte',
      dateLabel: 'Ontem',
      itemsCount: 15,
      total: 2150.00,
      status: OrderStatus.sent,
      isToday: false,
    ),
    const OrderSummary(
      id: '8940',
      code: '#PED-8940',
      clientName: 'Hospedagem Vale Verde',
      dateLabel: '22 Out',
      itemsCount: 3,
      total: 540.00,
      status: OrderStatus.draft,
      isToday: false,
    ),
  ];

  int _nextSequence = 9083;

  void _restorePendingFromBox() {
    for (final record in _pendingOrdersBox.values) {
      _orders.insert(
        0,
        OrderSummary(
          id: record.id,
          code: record.code,
          clientName: record.clientName,
          dateLabel: record.dateLabel,
          itemsCount: record.itemsCount,
          total: record.total,
          status: OrderStatus.pending,
          isToday: true,
        ),
      );
      final restoredSequence = int.tryParse(record.id);
      if (restoredSequence != null && restoredSequence >= _nextSequence) {
        _nextSequence = restoredSequence + 1;
      }
    }
  }

  @override
  Future<List<OrderSummary>> fetchOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_orders);
  }

  @override
  Future<OrderSummary> createOrder({
    required String clientName,
    required int itemsCount,
    required double total,
    required bool isDraft,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sequence = _nextSequence++;
    final order = OrderSummary(
      id: '$sequence',
      code: '#PED-$sequence',
      clientName: clientName,
      dateLabel: 'Hoje, ${AppFormatters.timeOfDay(DateTime.now())}',
      itemsCount: itemsCount,
      total: total,
      status: isDraft ? OrderStatus.draft : OrderStatus.pending,
      isToday: true,
    );
    _orders.insert(0, order);
    if (!isDraft) {
      // Não aguarda o flush em disco: `Box.put` já atualiza o estado em
      // memória da box na hora (por isso o restore em
      // `_restorePendingFromBox` funciona mesmo sem esperar aqui), e
      // aguardar a escrita real trava dentro do `FakeAsync` do
      // `flutter_test` (I/O de verdade não avança com `tester.pump`).
      unawaited(
        _pendingOrdersBox.put(
          order.id,
          OfflineOrderRecord(
            id: order.id,
            code: order.code,
            clientName: order.clientName,
            itemsCount: order.itemsCount,
            total: order.total,
            dateLabel: order.dateLabel,
          ),
        ),
      );
    }
    return order;
  }

  @override
  Future<int> syncPendingOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    var syncedCount = 0;
    for (var i = 0; i < _orders.length; i++) {
      if (_orders[i].status == OrderStatus.pending) {
        _orders[i] = _orders[i].copyWith(status: OrderStatus.sent);
        unawaited(_pendingOrdersBox.delete(_orders[i].id));
        syncedCount++;
      }
    }
    return syncedCount;
  }
}
