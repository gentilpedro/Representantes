import '../entities/cart_item.dart';
import '../entities/order_summary.dart';

/// Contrato de pedidos, contra a Web API .NET 10 (`GET /api/orders`,
/// `POST /api/orders`, `POST /api/orders/sync`).
abstract class OrdersRepository {
  Future<List<OrderSummary>> fetchOrders();

  /// Cria um pedido no servidor a partir do carrinho em construção. Se
  /// [isDraft] for falso, o pedido entra como `pending` — aguardando na fila
  /// de sincronização — até ser enviado. Rascunhos (`isDraft: true`) nunca
  /// entram na fila de sincronização. O servidor calcula subtotal, descontos,
  /// impostos e total a partir de [items].
  Future<OrderSummary> createOrder({
    required String clientId,
    required String clientName,
    required List<CartItem> items,
    String? notes,
    required bool isDraft,
  });

  /// Marca todos os pedidos `pending` do representante autenticado como
  /// `sent` no servidor. Devolve quantos pedidos foram sincronizados.
  Future<int> syncPendingOrders();
}
