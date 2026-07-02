/// Nomes das boxes Hive abertas em `main()` antes do app rodar (ver
/// [registerHiveAdapters] e a chamada a `Hive.openBox` em `main.dart`).
/// Centralizado aqui para as boxes e os providers que as expõem
/// (`core_providers.dart`) usarem exatamente a mesma string.
class HiveBoxes {
  HiveBoxes._();

  /// Fila de pedidos feitos offline aguardando sincronização (outbox) —
  /// registros somem assim que o pedido é sincronizado.
  static const pendingOrders = 'pending_orders';

  /// Cache do catálogo de produtos, atualizado periodicamente pelo servidor.
  static const productsCache = 'products_cache';

  /// Cache da carteira de clientes, atualizado periodicamente pelo servidor.
  static const clientsCache = 'clients_cache';

  /// Cache de clientes em potencial (leads), atualizado periodicamente pelo
  /// servidor.
  static const leadsCache = 'leads_cache';
}
