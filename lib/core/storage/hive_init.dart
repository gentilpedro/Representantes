import 'package:hive/hive.dart';

import '../../features/catalog/data/local/cached_product.dart';
import '../../features/clients/data/local/cached_client.dart';
import '../../features/leads/data/local/cached_lead.dart';
import '../../features/orders/data/local/offline_order_record.dart';
import 'hive_boxes.dart';

/// Registra os adapters e abre todas as boxes usadas pelo app. Chamado uma
/// vez em `main()` antes do `runApp` (depois de `Hive.initFlutter()`), e
/// também no setup dos testes de widget que tocam
/// pedidos/catálogo/clientes/leads (ver `test/support/hive_test_setup.dart`,
/// que chama `Hive.init()` com uma pasta temporária antes disto).
Future<void> initHive() async {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(OfflineOrderRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CachedProductAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CachedClientAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(CachedLeadAdapter());
  }

  await Future.wait([
    Hive.openBox<OfflineOrderRecord>(HiveBoxes.pendingOrders),
    Hive.openBox<CachedProduct>(HiveBoxes.productsCache),
    Hive.openBox<CachedClient>(HiveBoxes.clientsCache),
    Hive.openBox<CachedLead>(HiveBoxes.leadsCache),
  ]);
}
