import 'package:josapar_representantes/features/orders/domain/entities/cart_item.dart';
import 'package:josapar_representantes/features/orders/domain/entities/order_summary.dart';
import 'package:josapar_representantes/features/orders/domain/repositories/orders_repository.dart';

class FakeOrdersRepository implements OrdersRepository {
  FakeOrdersRepository({List<OrderSummary>? seed})
    : _orders = List.of(seed ?? _defaultSeed);

  static final _defaultSeed = <OrderSummary>[
    const OrderSummary(
      id: 'o1',
      code: '#PED-9082',
      clientName: 'Distribuidora Rio Grande',
      dateLabel: 'Hoje, 10:45',
      itemsCount: 3,
      total: 452.30,
      status: OrderStatus.sent,
      isToday: true,
    ),
    const OrderSummary(
      id: 'o2',
      code: '#PED-8940',
      clientName: 'Restaurante Central Buffet',
      dateLabel: 'Ontem',
      itemsCount: 5,
      total: 812.10,
      status: OrderStatus.error,
      isToday: false,
    ),
  ];

  final List<OrderSummary> _orders;
  int _sequence = 9500;

  @override
  Future<List<OrderSummary>> fetchOrders() async => List.of(_orders);

  @override
  Future<OrderSummary> createOrder({
    required String clientId,
    required String clientName,
    required List<CartItem> items,
    String? notes,
    required bool isDraft,
  }) async {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    _sequence++;
    final order = OrderSummary(
      id: 'order-$_sequence',
      code: '#PED-$_sequence',
      clientName: clientName,
      dateLabel: 'Hoje, agora',
      itemsCount: items.length,
      total: subtotal * 1.08,
      status: isDraft ? OrderStatus.draft : OrderStatus.pending,
      isToday: true,
    );
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<int> syncPendingOrders() async {
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
