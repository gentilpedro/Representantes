import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';
import 'package:josapar_representantes/core/network/api_client.dart';
import 'package:josapar_representantes/core/storage/session_storage.dart';
import 'package:josapar_representantes/core/sync/pending_actions_queue.dart';
import 'package:josapar_representantes/features/leads/data/repositories/api_leads_repository.dart';
import 'package:josapar_representantes/features/leads/domain/entities/lead.dart';

import 'fakes/fake_connectivity_service.dart';

void main() {
  late AppDatabase db;
  late ApiLeadsRepository repository;
  late FakeConnectivityService connectivity;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    connectivity = FakeConnectivityService(isOnline: false);
    final apiClient = ApiClient(SessionStorage(const FlutterSecureStorage()));
    repository = ApiLeadsRepository(
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
    'criar lead offline gera um registro provisório e enfileira a criação',
    () async {
      final lead = await repository.createLead(
        contactName: 'Fernanda Costa',
        companyName: 'Mercado Central',
        phone: '(51) 99000-1234',
        source: 'Feira do setor',
      );

      expect(lead.id, startsWith('offline-'));
      expect(lead.status, LeadStatus.new_);
      expect(lead.contactName, 'Fernanda Costa');

      final pending = await db.fetchPendingActions();
      expect(pending, hasLength(1));
      expect(pending.single.actionType, 'createLead');
    },
  );

  test(
    'criar lead offline entra na lista já cacheada',
    () async {
      await db.upsertJsonCache(
        'leads',
        jsonEncode([
          {
            'id': 'l1',
            'contactName': 'Existente',
            'companyName': 'Empresa X',
            'phone': '(51) 90000-0000',
            'status': 'new',
            'createdAtUtc': '2026-07-01T00:00:00Z',
          },
        ]),
      );

      await repository.createLead(
        contactName: 'Novo Contato',
        companyName: 'Nova Empresa',
        phone: '(51) 91111-1111',
      );

      final cachedList = jsonDecode((await db.fetchJsonCache('leads'))!) as List;
      expect(cachedList, hasLength(2));
      expect(cachedList.first['contactName'], 'Novo Contato');
    },
  );

  test(
    'atualizar lead offline atualiza o cache (detalhe + lista) e enfileira',
    () async {
      await db.upsertJsonCache(
        'lead:l1',
        jsonEncode({
          'id': 'l1',
          'contactName': 'Joana Martins',
          'companyName': 'Mercearia do Bairro',
          'phone': '(51) 98888-1111',
          'status': 'new',
          'createdAtUtc': '2026-06-20T00:00:00Z',
        }),
      );
      await db.upsertJsonCache(
        'leads',
        jsonEncode([
          {
            'id': 'l1',
            'contactName': 'Joana Martins',
            'companyName': 'Mercearia do Bairro',
            'phone': '(51) 98888-1111',
            'status': 'new',
            'createdAtUtc': '2026-06-20T00:00:00Z',
          },
        ]),
      );

      final updated = await repository.updateLead(
        id: 'l1',
        contactName: 'Joana Martins',
        companyName: 'Mercearia do Bairro',
        phone: '(51) 98888-1111',
        status: LeadStatus.contacted,
        notes: 'Primeiro contato feito por telefone.',
      );

      expect(updated.status, LeadStatus.contacted);
      // `createdAtUtc` original preservado, não substituído por "agora".
      expect(updated.createdAtUtc, DateTime.utc(2026, 6, 20));

      final cachedDetail =
          jsonDecode((await db.fetchJsonCache('lead:l1'))!)
              as Map<String, dynamic>;
      expect(cachedDetail['status'], 'contacted');

      final cachedList =
          jsonDecode((await db.fetchJsonCache('leads'))!) as List;
      expect(cachedList.single['status'], 'contacted');

      final pending = await db.fetchPendingActions();
      expect(pending, hasLength(1));
      expect(pending.single.actionType, 'updateLead');
      expect(pending.single.payload, contains('"id":"l1"'));
    },
  );
}
