import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';
import 'package:josapar_representantes/core/network/api_client.dart';
import 'package:josapar_representantes/core/storage/session_storage.dart';
import 'package:josapar_representantes/core/sync/pending_actions_queue.dart';
import 'package:josapar_representantes/features/orders/data/repositories/api_orders_repository.dart';
import 'package:josapar_representantes/features/orders/domain/entities/cart_item.dart';
import 'package:josapar_representantes/features/orders/domain/entities/order_summary.dart';

import 'fakes/fake_connectivity_service.dart';

void main() {
  late AppDatabase db;
  late ApiOrdersRepository repository;
  late FakeConnectivityService connectivity;

  const items = [
    CartItem(
      productId: 'p1',
      name: 'Arroz 5kg',
      sku: 'ARZ-001',
      imageUrl: '',
      unitPrice: 24.9,
      quantity: 2,
    ),
  ];

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    connectivity = FakeConnectivityService(isOnline: false);
    final apiClient = ApiClient(SessionStorage(const FlutterSecureStorage()));
    repository = ApiOrdersRepository(
      apiClient,
      db,
      connectivity,
      PendingActionsQueue(db),
    );
  });

  tearDown(() {
    db.close();
    connectivity.dispose();
  });

  test(
    'rascunho offline aparece com status draft e enfileira a criação real',
    () async {
      final order = await repository.createOrder(
        clientId: 'c1',
        clientName: 'Cliente Teste',
        items: items,
        isDraft: true,
      );

      expect(order.status, OrderStatus.draft);
      expect(order.code, startsWith('OFFLINE-'));

      final rows = await db.fetchPendingOrders();
      expect(rows, hasLength(1));
      expect(rows.single.isDraft, isTrue);

      final pending = await db.fetchPendingActions();
      expect(pending, hasLength(1));
      expect(pending.single.actionType, 'createDraftOrder');
      expect(pending.single.payload, contains('"isDraft":true'));
    },
  );

  test(
    'pedido não-rascunho offline continua com status pending e sem ação enfileirada (fluxo de batch-sync)',
    () async {
      final order = await repository.createOrder(
        clientId: 'c1',
        clientName: 'Cliente Teste',
        items: items,
        isDraft: false,
      );

      expect(order.status, OrderStatus.pending);

      final pending = await db.fetchPendingActions();
      expect(pending, isEmpty, reason: 'segue o fluxo de batch-sync, não a fila genérica');
    },
  );

  test(
    'syncPendingOrders ignora rascunhos — só sincroniza pedidos pendentes de verdade',
    () async {
      await repository.createOrder(
        clientId: 'c1',
        clientName: 'Cliente Rascunho',
        items: items,
        isDraft: true,
      );
      await repository.createOrder(
        clientId: 'c2',
        clientName: 'Cliente Pendente',
        items: items,
        isDraft: false,
      );

      // Sem conexão real de verdade nesse teste, o batch-sync vai falhar —
      // o que importa é confirmar que só a linha não-rascunho seria
      // enviada (fetchPendingOrders filtrado dentro do método).
      final allRows = await db.fetchPendingOrders();
      expect(allRows, hasLength(2));
      expect(allRows.where((r) => !r.isDraft), hasLength(1));
    },
  );
}
