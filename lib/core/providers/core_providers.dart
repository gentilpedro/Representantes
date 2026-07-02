import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import '../../features/catalog/data/local/cached_product.dart';
import '../../features/clients/data/local/cached_client.dart';
import '../../features/leads/data/local/cached_lead.dart';
import '../../features/orders/data/local/offline_order_record.dart';
import '../network/api_client.dart';
import '../services/connectivity_service.dart';
import '../storage/hive_boxes.dart';
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

// As boxes abaixo já foram abertas em `main()` antes do app subir (ver
// `registerHiveAdapters`/`openHiveBoxes`), então `Hive.box` aqui é só uma
// leitura síncrona da instância já em memória — sem isso, providers async
// teriam que se espalhar por todos os repositórios que dependem delas.
final pendingOrdersBoxProvider = Provider<Box<OfflineOrderRecord>>((ref) {
  return Hive.box<OfflineOrderRecord>(HiveBoxes.pendingOrders);
});

final productsCacheBoxProvider = Provider<Box<CachedProduct>>((ref) {
  return Hive.box<CachedProduct>(HiveBoxes.productsCache);
});

final clientsCacheBoxProvider = Provider<Box<CachedClient>>((ref) {
  return Hive.box<CachedClient>(HiveBoxes.clientsCache);
});

final leadsCacheBoxProvider = Provider<Box<CachedLead>>((ref) {
  return Hive.box<CachedLead>(HiveBoxes.leadsCache);
});
