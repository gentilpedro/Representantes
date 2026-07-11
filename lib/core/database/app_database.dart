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

@DriftDatabase(
  tables: [
    SyncMetadataTable,
    PendingOrdersTable,
    PendingOrderItemsTable,
    ProductsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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

  Future<List<PendingOrderItemsTableData>> fetchPendingOrderItems(String orderId) =>
      (select(pendingOrderItemsTable)
            ..where((t) => t.orderId.equals(orderId)))
          .get();

  Future<void> deletePendingOrder(String id) {
    return transaction(() async {
      await (delete(pendingOrderItemsTable)..where((t) => t.orderId.equals(id))).go();
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
