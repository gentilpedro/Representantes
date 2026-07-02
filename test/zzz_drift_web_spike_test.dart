import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';

void main() {
  test('drift opens and round-trips on the web (wasm/IndexedDB)', () async {
    final db = AppDatabase();
    try {
      await db
          .into(db.syncMetadataTable)
          .insert(
            SyncMetadataTableCompanion.insert(
              dataset: 'spike',
              lastSyncedAt: DateTime(2026, 1, 1),
            ),
          );
      final rows = await db.select(db.syncMetadataTable).get();
      expect(rows, hasLength(1));
      expect(rows.single.dataset, 'spike');
    } finally {
      await db.close();
    }
  });
}
