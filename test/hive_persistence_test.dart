import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:josapar_representantes/core/storage/hive_boxes.dart';
import 'package:josapar_representantes/core/storage/hive_init.dart';
import 'package:josapar_representantes/features/catalog/data/local/cached_product.dart';
import 'package:josapar_representantes/features/catalog/data/repositories/mock_catalog_repository.dart';
import 'package:josapar_representantes/features/orders/data/local/offline_order_record.dart';
import 'package:josapar_representantes/features/orders/data/repositories/mock_orders_repository.dart';
import 'package:josapar_representantes/features/orders/domain/entities/order_summary.dart';

/// Prova a durabilidade real da persistência local: cria os repositórios
/// duas vezes sobre a *mesma* pasta/boxes Hive, simulando um restart do app
/// (ou um refresh da página web) — sem passar pela árvore de widgets, então
/// sem o problema de `FakeAsync` visto nos outros testes.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('josapar_persistence_test_');
    Hive.init(tempDir.path);
    await initHive();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test(
    'pedido pendente sobrevive a um "restart" (reabrir a mesma box)',
    () async {
      final pendingBox = Hive.box<OfflineOrderRecord>(HiveBoxes.pendingOrders);

      final firstRun = MockOrdersRepository(pendingBox);
      final created = await firstRun.createOrder(
        clientName: 'Cliente Offline Teste',
        itemsCount: 3,
        total: 199.90,
        isDraft: false,
      );

      // A escrita na box não é aguardada (ver comentário em
      // `MockOrdersRepository.createOrder`), mas já reflete no estado em
      // memória da box na hora — não precisa de delay aqui.
      expect(pendingBox.containsKey(created.id), isTrue);

      // "Restart": nova instância do repositório sobre a MESMA box.
      final secondRun = MockOrdersRepository(pendingBox);
      final restoredOrders = await secondRun.fetchOrders();

      final restored = restoredOrders.firstWhere((o) => o.id == created.id);
      expect(restored.status, OrderStatus.pending);
      expect(restored.clientName, 'Cliente Offline Teste');
      expect(restored.total, 199.90);

      // Sincroniza na "segunda sessão" — o registro deve sumir da box.
      await secondRun.syncPendingOrders();
      expect(pendingBox.containsKey(created.id), isFalse);
    },
  );

  test(
    'rascunho não sobrevive a um "restart" (nunca entra na box de pendentes)',
    () async {
      final pendingBox = Hive.box<OfflineOrderRecord>(HiveBoxes.pendingOrders);

      final firstRun = MockOrdersRepository(pendingBox);
      final draft = await firstRun.createOrder(
        clientName: 'Rascunho Teste',
        itemsCount: 1,
        total: 10.0,
        isDraft: true,
      );

      expect(pendingBox.containsKey(draft.id), isFalse);

      final secondRun = MockOrdersRepository(pendingBox);
      final restoredOrders = await secondRun.fetchOrders();
      expect(restoredOrders.any((o) => o.id == draft.id), isFalse);
    },
  );

  test(
    'cache de produtos é semeado uma vez e reaproveitado entre "restarts"',
    () async {
      final productsBox = Hive.box<CachedProduct>(HiveBoxes.productsCache);

      final firstRun = MockCatalogRepository(productsBox);
      final firstProducts = await firstRun.fetchProducts();
      expect(firstProducts, isNotEmpty);
      expect(firstProducts.first.name, 'Arroz Tio João Tipo 1');

      final secondRun = MockCatalogRepository(productsBox);
      final secondProducts = await secondRun.fetchProducts();

      // Mesma quantidade e mesma ordem — nada foi re-semeado nem embaralhado.
      expect(secondProducts.length, firstProducts.length);
      expect(
        secondProducts.map((p) => p.id).toList(),
        firstProducts.map((p) => p.id).toList(),
      );
    },
  );
}
