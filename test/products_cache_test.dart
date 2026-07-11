import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProductsTableCompanion product(String id, {String name = 'Arroz'}) {
    return ProductsTableCompanion.insert(
      id: id,
      sku: 'SKU-$id',
      brand: 'Josapar',
      name: name,
      category: 'Arroz',
      imageUrl: 'https://picsum.photos/seed/$id/400',
      price: 10,
      availableUnits: 100,
      originalPrice: const Value(null),
      badge: 'none',
    );
  }

  test('replaceAllProducts baixa e persiste o catálogo localmente', () async {
    await db.replaceAllProducts([product('p1'), product('p2')]);

    final rows = await db.fetchAllProducts();

    expect(rows, hasLength(2));
    expect(rows.map((r) => r.id), containsAll(['p1', 'p2']));
  });

  test(
    'replaceAllProducts substitui o catálogo anterior (servidor é a fonte da verdade)',
    () async {
      await db.replaceAllProducts([product('p1'), product('p2')]);
      await db.replaceAllProducts([product('p3')]);

      final rows = await db.fetchAllProducts();

      expect(rows, hasLength(1));
      expect(rows.single.id, 'p3');
    },
  );

  test('upsertSyncMetadata grava e depois atualiza a última sincronização', () async {
    await db.upsertSyncMetadata('products', DateTime(2026, 1, 1));
    await db.upsertSyncMetadata('products', DateTime(2026, 1, 2));

    final rows = await db.select(db.syncMetadataTable).get();

    expect(rows, hasLength(1));
    expect(rows.single.lastSyncedAt, DateTime(2026, 1, 2));
  });
}
