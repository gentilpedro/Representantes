import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/repositories/orders_repository.dart';

/// Dados em memória espelhando a tela "Meus Pedidos" do protótipo. Mantém
/// uma lista mutável (não apenas fixa) para que pedidos criados em "Novo
/// Pedido" e sincronizações apareçam de verdade nesta lista, exatamente como
/// a implementação real (contra a Web API .NET 10) fará.
class MockOrdersRepository implements OrdersRepository {
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
    return order;
  }

  @override
  Future<int> syncPendingOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    var syncedCount = 0;
    for (var i = 0; i < _orders.length; i++) {
      if (_orders[i].status == OrderStatus.pending) {
        _orders[i] = _orders[i].copyWith(status: OrderStatus.sent);
        syncedCount++;
      }
    }
    return syncedCount;
  }
}
