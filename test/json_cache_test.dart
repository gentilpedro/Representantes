import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josapar_representantes/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('upsertJsonCache grava e depois atualiza pela mesma chave', () async {
    await db.upsertJsonCache('dashboard', '{"salesToday":1}');
    await db.upsertJsonCache('dashboard', '{"salesToday":2}');

    final cached = await db.fetchJsonCache('dashboard');

    expect(cached, '{"salesToday":2}');
  });

  test('chaves diferentes (ex: períodos de relatório) não se sobrescrevem', () async {
    await db.upsertJsonCache('reports:today', '{"totalSales":1}');
    await db.upsertJsonCache('reports:month', '{"totalSales":2}');

    expect(await db.fetchJsonCache('reports:today'), '{"totalSales":1}');
    expect(await db.fetchJsonCache('reports:month'), '{"totalSales":2}');
  });

  test('fetchJsonCache retorna null quando não há cache pra chave', () async {
    final cached = await db.fetchJsonCache('permissions');

    expect(cached, isNull);
  });
}
