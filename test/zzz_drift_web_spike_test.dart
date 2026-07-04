import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';

void main() {
  test('drift opens and round-trips (in-memory)', () async {
    // Banco em memória: independe de `path_provider`/canais de plataforma,
    // que exigiriam um binding do Flutter (`AppDatabase()` sem executor usa
    // `drift_flutter`, que chama `getTemporaryDirectory()`).
    final db = AppDatabase(NativeDatabase.memory());
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
