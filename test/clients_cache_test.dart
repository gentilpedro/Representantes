import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ClientsTableCompanion client(String id, {bool isFavorite = false}) {
    return ClientsTableCompanion.insert(
      id: id,
      code: 'CLI-$id',
      name: 'Cliente $id',
      cnpj: '00.000.000/0001-00',
      city: 'Porto Alegre',
      state: 'RS',
      tier: 'regular',
      lastOrderAtUtc: Value(DateTime.utc(2026, 7, 1)),
      creditLimit: 10000,
      isFavorite: Value(isFavorite),
    );
  }

  test('replaceAllClients baixa e persiste o cadastro localmente', () async {
    await db.replaceAllClients([client('c1'), client('c2')]);

    final rows = await db.fetchAllClients();

    expect(rows, hasLength(2));
    expect(rows.map((r) => r.id), containsAll(['c1', 'c2']));
  });

  test(
    'replaceAllClients substitui o cadastro anterior (servidor é a fonte da verdade)',
    () async {
      await db.replaceAllClients([client('c1'), client('c2')]);
      await db.replaceAllClients([client('c3')]);

      final rows = await db.fetchAllClients();

      expect(rows, hasLength(1));
      expect(rows.single.id, 'c3');
    },
  );

  test(
    'updateCachedClientFavorite atualiza só o favorito sem apagar o resto',
    () async {
      await db.replaceAllClients([client('c1'), client('c2')]);

      await db.updateCachedClientFavorite('c1', true);

      final rows = await db.fetchAllClients();
      final c1 = rows.firstWhere((r) => r.id == 'c1');
      final c2 = rows.firstWhere((r) => r.id == 'c2');
      expect(c1.isFavorite, isTrue);
      expect(c2.isFavorite, isFalse);
    },
  );

  test(
    'upsertClientDetailJson grava e depois atualiza o detalhe em cache',
    () async {
      await db.upsertClientDetailJson('c1', '{"name":"Old"}');
      await db.upsertClientDetailJson('c1', '{"name":"New"}');

      final cached = await db.fetchClientDetailJson('c1');

      expect(cached, '{"name":"New"}');
    },
  );

  test('fetchClientDetailJson retorna null quando não há cache', () async {
    final cached = await db.fetchClientDetailJson('nao-existe');

    expect(cached, isNull);
  });
}
