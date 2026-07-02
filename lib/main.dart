import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: JosaparRepresentantesApp()));
}

class JosaparRepresentantesApp extends ConsumerWidget {
  const JosaparRepresentantesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // SPIKE TEMPORÁRIO: força a abertura do Drift pra validar que funciona
    // de verdade na Web (wasm/IndexedDB) antes de construir o schema
    // completo — remover depois de confirmado.
    Future.microtask(() async {
      final db = ref.read(appDatabaseProvider);
      try {
        await db
            .into(db.syncMetadataTable)
            .insertOnConflictUpdate(
              SyncMetadataTableCompanion.insert(
                dataset: 'spike',
                lastSyncedAt: DateTime.now(),
              ),
            );
        final rows = await db.select(db.syncMetadataTable).get();
        // ignore: avoid_print
        print('DRIFT SPIKE OK: ${rows.length} row(s) — ${rows.map((r) => r.dataset)}');
      } catch (e, st) {
        // ignore: avoid_print
        print('DRIFT SPIKE FAILED: $e\n$st');
      }
    });

    return MaterialApp.router(
      title: 'Josapar Representantes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
