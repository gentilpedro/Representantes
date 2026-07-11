import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Espelha `SyncMetadata` — quando cada dataset sincronizado do servidor
/// (materiais, clientes, leads) foi atualizado pela última vez.
class SyncMetadataTable extends Table {
  TextColumn get dataset => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {dataset};
}

/// Pedidos finalizados sem conexão, aguardando envio pra
/// `POST /api/orders/batch-sync`. `id` é o `ClientGeneratedId` (chave de
/// idempotência do sync) — nunca um rascunho (`draft`) entra aqui.
class PendingOrdersTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get clientName => text()();
  TextColumn get notes => text().nullable()();
  RealColumn get total => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Itens de um [PendingOrdersTable] — snapshot do carrinho no momento da
/// criação offline (mesmos dados de `CartItem`).
class PendingOrderItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get productSku => text()();
  RealColumn get unitPrice => real()();
  IntColumn get quantity => integer()();
  RealColumn get discountPercent => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Catálogo de produtos baixado do servidor (`GET /api/products`) — permite
/// que o representante consulte e monte pedidos mesmo sem conexão. É
/// totalmente substituído a cada sincronização bem-sucedida (não há merge
/// incremental: o servidor é sempre a fonte da verdade).
class ProductsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sku => text()();
  TextColumn get brand => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get imageUrl => text()();
  RealColumn get price => real()();
  IntColumn get availableUnits => integer()();
  RealColumn get originalPrice => real().nullable()();
  TextColumn get badge => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Clientes baixados do servidor (`GET /api/clients`) — permite consultar e
/// selecionar cliente pra um pedido mesmo sem conexão. Mesmo padrão do
/// [ProductsTable]: substituído por inteiro a cada sincronização.
class ClientsTable extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get cnpj => text()();
  TextColumn get city => text()();
  TextColumn get state => text()();
  TextColumn get tier => text()();
  DateTimeColumn get lastOrderAtUtc => dateTime().nullable()();
  RealColumn get creditLimit => real()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache do detalhe de cada cliente já visitado com conexão (`GET
/// /api/clients/{id}`) — guarda a resposta bruta em JSON pra reaproveitar o
/// mesmo parser da chamada online quando offline.
class ClientDetailsCacheTable extends Table {
  TextColumn get clientId => text()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {clientId};
}

/// Cache da agenda do dia (`GET /api/agenda?date=`) — uma linha por data já
/// consultada com conexão, guardada em JSON bruto (mesma ideia do
/// [ClientDetailsCacheTable]) pra reaproveitar o parser existente.
class AgendaCacheTable extends Table {
  TextColumn get date => text()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(
  tables: [
    SyncMetadataTable,
    PendingOrdersTable,
    PendingOrderItemsTable,
    ProductsTable,
    ClientsTable,
    ClientDetailsCacheTable,
    AgendaCacheTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(pendingOrdersTable);
        await m.createTable(pendingOrderItemsTable);
      }
      if (from < 3) {
        await m.createTable(productsTable);
      }
      if (from < 4) {
        await m.createTable(clientsTable);
        await m.createTable(clientDetailsCacheTable);
      }
      if (from < 5) {
        await m.createTable(agendaCacheTable);
      }
    },
  );

  /// Grava um pedido offline (cabeçalho + itens) numa única transação.
  Future<void> savePendingOrder({
    required String id,
    required String clientId,
    required String clientName,
    String? notes,
    required double total,
    required DateTime createdAt,
    required List<PendingOrderItemsTableCompanion> items,
  }) {
    return transaction(() async {
      await into(pendingOrdersTable).insert(
        PendingOrdersTableCompanion.insert(
          id: id,
          clientId: clientId,
          clientName: clientName,
          notes: Value(notes),
          total: total,
          createdAt: createdAt,
        ),
      );
      for (final item in items) {
        await into(pendingOrderItemsTable).insert(item);
      }
    });
  }

  Future<List<PendingOrdersTableData>> fetchPendingOrders() =>
      select(pendingOrdersTable).get();

  Future<List<PendingOrderItemsTableData>> fetchPendingOrderItems(
    String orderId,
  ) => (select(
    pendingOrderItemsTable,
  )..where((t) => t.orderId.equals(orderId))).get();

  Future<void> deletePendingOrder(String id) {
    return transaction(() async {
      await (delete(
        pendingOrderItemsTable,
      )..where((t) => t.orderId.equals(id))).go();
      await (delete(pendingOrdersTable)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Substitui todo o catálogo local pelo lote baixado do servidor. Sem
  /// merge incremental: o servidor é sempre a fonte da verdade, então cada
  /// sincronização bem-sucedida apaga e regrava tudo numa única transação.
  Future<void> replaceAllProducts(List<ProductsTableCompanion> products) {
    return transaction(() async {
      await delete(productsTable).go();
      await batch((b) => b.insertAll(productsTable, products));
    });
  }

  Future<List<ProductsTableData>> fetchAllProducts() =>
      select(productsTable).get();

  Future<void> upsertSyncMetadata(String dataset, DateTime syncedAt) {
    return into(syncMetadataTable).insertOnConflictUpdate(
      SyncMetadataTableCompanion.insert(
        dataset: dataset,
        lastSyncedAt: syncedAt,
      ),
    );
  }

  /// Substitui todo o cadastro de clientes local pelo lote baixado do
  /// servidor — mesma lógica de [replaceAllProducts].
  Future<void> replaceAllClients(List<ClientsTableCompanion> clients) {
    return transaction(() async {
      await delete(clientsTable).go();
      await batch((b) => b.insertAll(clientsTable, clients));
    });
  }

  Future<List<ClientsTableData>> fetchAllClients() =>
      select(clientsTable).get();

  /// Mantém o cache do favorito em dia sem precisar rebaixar a lista
  /// inteira — usado depois de um `PATCH /favorite` bem-sucedido.
  Future<void> updateCachedClientFavorite(String clientId, bool isFavorite) {
    return (update(clientsTable)..where((t) => t.id.equals(clientId))).write(
      ClientsTableCompanion(isFavorite: Value(isFavorite)),
    );
  }

  Future<void> upsertClientDetailJson(String clientId, String json) {
    return into(clientDetailsCacheTable).insertOnConflictUpdate(
      ClientDetailsCacheTableCompanion.insert(clientId: clientId, json: json),
    );
  }

  Future<String?> fetchClientDetailJson(String clientId) async {
    final row = await (select(
      clientDetailsCacheTable,
    )..where((t) => t.clientId.equals(clientId))).getSingleOrNull();
    return row?.json;
  }

  Future<void> upsertAgendaJson(String date, String json) {
    return into(agendaCacheTable).insertOnConflictUpdate(
      AgendaCacheTableCompanion.insert(date: date, json: json),
    );
  }

  Future<String?> fetchAgendaJson(String date) async {
    final row = await (select(
      agendaCacheTable,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
    return row?.json;
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'josapar_representantes_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
