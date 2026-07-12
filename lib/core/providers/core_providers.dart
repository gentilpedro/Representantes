import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../database/app_database.dart';
import '../network/api_client.dart';
import '../services/connectivity_service.dart';
import '../storage/session_storage.dart';
import '../sync/pending_actions_queue.dart';
import '../sync/pending_actions_syncer.dart';

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

/// Fila de ações de escrita feitas offline (favoritar/criar cliente,
/// check-in/check-out/criar visita, criar/atualizar lead) — ver
/// `lib/core/sync/pending_actions_queue.dart`.
final pendingActionsQueueProvider = Provider<PendingActionsQueue>((ref) {
  return PendingActionsQueue(ref.watch(appDatabaseProvider));
});

/// Reenvia a fila acima assim que a conexão volta — disparado pelo mesmo
/// listener de conectividade que já sincroniza pedidos offline (ver
/// `SyncController`).
final pendingActionsSyncerProvider = Provider<PendingActionsSyncerBase>((ref) {
  return PendingActionsSyncer(
    ref.watch(appDatabaseProvider),
    ref.watch(apiClientProvider),
  );
});

/// Versão/build reais do app, lidos do `pubspec.yaml` (embutidos no binário
/// no momento do build) — usado pra exibir a versão de verdade em vez de um
/// texto fixo, essencial pra identificar builds durante o beta.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// `v1.0.0 (3)` — versão + build number, formato usado nas telas de Boas-
/// vindas e Perfil.
String formatAppVersion(PackageInfo info) =>
    'v${info.version} (${info.buildNumber})';
