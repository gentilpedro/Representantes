import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('upsertAgendaJson grava e depois atualiza a agenda em cache', () async {
    await db.upsertAgendaJson('2026-07-11', '{"visitsPlanned":1}');
    await db.upsertAgendaJson('2026-07-11', '{"visitsPlanned":3}');

    final cached = await db.fetchAgendaJson('2026-07-11');

    expect(cached, '{"visitsPlanned":3}');
  });

  test('cada data guarda seu próprio cache, independente', () async {
    await db.upsertAgendaJson('2026-07-11', '{"visitsPlanned":1}');
    await db.upsertAgendaJson('2026-07-12', '{"visitsPlanned":5}');

    expect(await db.fetchAgendaJson('2026-07-11'), '{"visitsPlanned":1}');
    expect(await db.fetchAgendaJson('2026-07-12'), '{"visitsPlanned":5}');
  });

  test('fetchAgendaJson retorna null quando não há cache pra data', () async {
    final cached = await db.fetchAgendaJson('2026-01-01');

    expect(cached, isNull);
  });
}
