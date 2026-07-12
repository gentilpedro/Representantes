import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';
import 'package:josapar_representantes/core/network/api_client.dart';
import 'package:josapar_representantes/core/storage/session_storage.dart';
import 'package:josapar_representantes/core/sync/pending_actions_queue.dart';
import 'package:josapar_representantes/features/clients/data/repositories/api_clients_repository.dart';
import 'package:josapar_representantes/features/clients/domain/entities/client_detail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'fakes/fake_connectivity_service.dart';

void main() {
  late AppDatabase db;
  late ApiClientsRepository repository;
  late FakeConnectivityService connectivity;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    connectivity = FakeConnectivityService(isOnline: false);
    final apiClient = ApiClient(SessionStorage(const FlutterSecureStorage()));
    repository = ApiClientsRepository(
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
    'favoritar offline atualiza o cache na hora e enfileira a ação',
    () async {
      await db.replaceAllClients([
        ClientsTableCompanion.insert(
          id: 'c1',
          code: 'CLI-1',
          name: 'Cliente 1',
          cnpj: '00.000.000/0001-00',
          city: 'Porto Alegre',
          state: 'RS',
          tier: 'regular',
          creditLimit: 1000,
        ),
      ]);

      await repository.toggleFavorite('c1', true);

      final cached = await db.fetchAllClients();
      expect(cached.single.isFavorite, isTrue);

      final pending = await db.fetchPendingActions();
      expect(pending, hasLength(1));
      expect(pending.single.actionType, 'toggleClientFavorite');
      expect(pending.single.payload, contains('"clientId":"c1"'));
      expect(pending.single.payload, contains('"isFavorite":true'));
    },
  );

  test(
    'criar cliente offline gera um registro provisório e enfileira a criação',
    () async {
      final detail = await repository.createClient(
        name: 'Empório Novo',
        cnpj: '11.111.111/0001-11',
        phone: '(51) 3000-0000',
        mobile: '(51) 99000-0000',
        email: 'contato@emporio.example.com',
        creditLimit: 5000,
        deliveryAddress: const DeliveryAddress(
          street: 'Rua Nova, 1',
          district: 'Centro',
          city: 'Canoas',
          state: 'RS',
        ),
      );

      expect(detail.name, 'Empório Novo');
      expect(detail.id, startsWith('offline-'));
      expect(detail.code, startsWith('OFFLINE-'));

      final cachedList = await db.fetchAllClients();
      expect(cachedList, hasLength(1));
      expect(cachedList.single.name, 'Empório Novo');

      final pending = await db.fetchPendingActions();
      expect(pending, hasLength(1));
      expect(pending.single.actionType, 'createClient');
      expect(pending.single.payload, contains('Empório Novo'));
    },
  );
}
