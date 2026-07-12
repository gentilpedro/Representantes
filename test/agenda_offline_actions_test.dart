import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';
import 'package:josapar_representantes/core/network/api_client.dart';
import 'package:josapar_representantes/core/storage/session_storage.dart';
import 'package:josapar_representantes/core/sync/pending_actions_queue.dart';
import 'package:josapar_representantes/features/agenda/data/repositories/api_agenda_repository.dart';

import 'fakes/fake_connectivity_service.dart';

void main() {
  late AppDatabase db;
  late ApiAgendaRepository repository;
  late FakeConnectivityService connectivity;

  const isoDate = '2026-07-12';
  final date = DateTime(2026, 7, 12);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    connectivity = FakeConnectivityService(isOnline: false);
    final apiClient = ApiClient(SessionStorage(const FlutterSecureStorage()));
    repository = ApiAgendaRepository(
      apiClient,
      db,
      connectivity,
      PendingActionsQueue(db),
    );

    await db.upsertAgendaJson(
      isoDate,
      jsonEncode({
        'date': isoDate,
        'visitsPlanned': 1,
        'visits': [
          {
            'id': 'v1',
            'clientName': 'Mercado Bom Preço',
            'clientAddress': 'Rua X, 1 - Porto Alegre/RS',
            'scheduledAtUtc': '2026-07-12T12:00:00Z',
            'status': 'pending',
            'notes': '',
            'isGeoValidated': false,
          },
        ],
      }),
    );
  });

  tearDown(() {
    db.close();
    connectivity.dispose();
  });

  test(
    'check-in offline atualiza a visita no cache do dia e enfileira a ação',
    () async {
      await repository.checkIn('v1', date, latitude: -30.0, longitude: -51.2);

      final cached = jsonDecode(
        (await db.fetchAgendaJson(isoDate))!,
      );
      final visit = (cached['visits'] as List).single;
      expect(visit['status'], 'inProgress');
      expect(visit['isGeoValidated'], isTrue);

      final pending = await db.fetchPendingActions();
      expect(pending, hasLength(1));
      expect(pending.single.actionType, 'checkInVisit');
      expect(pending.single.payload, contains('"visitId":"v1"'));
    },
  );

  test(
    'check-out offline atualiza status/notas no cache e enfileira a ação',
    () async {
      await repository.checkOut('v1', date, 'Cliente confirmou reposição.');

      final cached = jsonDecode(
        (await db.fetchAgendaJson(isoDate))!,
      );
      final visit = (cached['visits'] as List).single;
      expect(visit['status'], 'completed');
      expect(visit['notes'], 'Cliente confirmou reposição.');

      final pending = await db.fetchPendingActions();
      expect(pending, hasLength(1));
      expect(pending.single.actionType, 'checkOutVisit');
    },
  );

  test(
    'criar visita offline adiciona uma visita provisória no cache do dia',
    () async {
      await db.insertClient(
        ClientsTableCompanion.insert(
          id: 'c1',
          code: 'CLI-1',
          name: 'Distribuidora Nova',
          cnpj: '00.000.000/0001-00',
          city: 'Canoas',
          state: 'RS',
          tier: 'regular',
          lastOrderAtUtc: const Value(null),
          creditLimit: 1000,
        ),
      );

      // Meio-dia UTC pra margem de sobra contra o fuso horário da máquina
      // que roda o teste — evita virar de dia no `.toLocal()` do
      // repositório e cair num cache de data diferente do seedado acima.
      final scheduledAtUtc = DateTime.utc(2026, 7, 12, 12);
      final scheduledLocal = scheduledAtUtc.toLocal();
      String pad(int n) => n.toString().padLeft(2, '0');
      final visitIsoDate =
          '${scheduledLocal.year}-${pad(scheduledLocal.month)}-${pad(scheduledLocal.day)}';
      expect(
        visitIsoDate,
        isoDate,
        reason: 'ajuste o horário UTC do teste se isso falhar no seu fuso',
      );

      await repository.createVisit(
        clientId: 'c1',
        scheduledAtUtc: scheduledAtUtc,
        notes: 'Levar catálogo novo.',
      );

      final cached = jsonDecode((await db.fetchAgendaJson(isoDate))!);
      expect(cached['visitsPlanned'], 2);
      final visits = cached['visits'] as List;
      expect(visits, hasLength(2));
      final newVisit = visits.firstWhere((v) => v['id'] != 'v1');
      expect(newVisit['clientName'], 'Distribuidora Nova');
      expect(newVisit['status'], 'pending');

      final pending = await db.fetchPendingActions();
      expect(pending, hasLength(1));
      expect(pending.single.actionType, 'createVisit');
    },
  );
}
