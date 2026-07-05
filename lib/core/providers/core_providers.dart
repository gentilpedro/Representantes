import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/app_database.dart';
import '../network/api_client.dart';
import '../services/connectivity_service.dart';
import '../storage/session_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage(ref.watch(secureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(sessionStorageProvider));
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Estado de conexão do app, com um valor inicial síncrono seguido pelas
/// mudanças em tempo real. `SyncController` observa isto para disparar a
/// sincronização automática assim que o dispositivo volta a ficar online.
final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield await service.isOnline();
  yield* service.onStatusChange;
});

/// Banco SQLite (Drift) de dados de referência sincronizados do servidor
/// (materiais, clientes, leads) — ver `lib/core/database/app_database.dart`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
