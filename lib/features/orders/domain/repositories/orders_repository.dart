import '../entities/order_summary.dart';

/// Contrato de pedidos. A implementação real deve consumir a Web API .NET 10
/// (ex: `GET /api/orders`, `POST /api/orders`).
abstract class OrdersRepository {
  Future<List<OrderSummary>> fetchOrders();

  /// Cria um pedido local. Se [isDraft] for falso, o pedido entra como
  /// `pending` — aguardando na fila de sincronização — até ser enviado.
  /// Rascunhos (`isDraft: true`) nunca entram na fila de sincronização.
  Future<OrderSummary> createOrder({
    required String clientName,
    required int itemsCount,
    required double total,
    required bool isDraft,
  });

  /// Marca todos os pedidos `pending` como `sent`, simulando o envio da fila
  /// para a Web API. Devolve quantos pedidos foram sincronizados.
  Future<int> syncPendingOrders();
}
