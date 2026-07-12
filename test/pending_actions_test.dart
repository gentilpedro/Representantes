import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('savePendingAction grava e fetchPendingActions devolve em ordem', () async {
    await db.savePendingAction(
      id: 'a1',
      actionType: 'toggleClientFavorite',
      payload: '{"clientId":"c1","isFavorite":true}',
      createdAt: DateTime.utc(2026, 7, 1, 10),
    );
    await db.savePendingAction(
      id: 'a2',
      actionType: 'createLead',
      payload: '{"contactName":"Joao"}',
      createdAt: DateTime.utc(2026, 7, 1, 9),
    );

    final actions = await db.fetchPendingActions();

    expect(actions, hasLength(2));
    // a2 foi criada antes (09h) que a1 (10h) — deve vir primeiro.
    expect(actions.map((a) => a.id), ['a2', 'a1']);
  });

  test('deletePendingAction remove só a ação indicada', () async {
    await db.savePendingAction(
      id: 'a1',
      actionType: 'checkInVisit',
      payload: '{}',
      createdAt: DateTime.utc(2026, 7, 1),
    );
    await db.savePendingAction(
      id: 'a2',
      actionType: 'checkOutVisit',
      payload: '{}',
      createdAt: DateTime.utc(2026, 7, 1),
    );

    await db.deletePendingAction('a1');

    final actions = await db.fetchPendingActions();
    expect(actions, hasLength(1));
    expect(actions.single.id, 'a2');
  });
}
