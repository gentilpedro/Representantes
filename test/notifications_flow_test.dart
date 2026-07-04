import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Fluxo de Notificações: lista, filtro de não lidas e marcar todas como lidas',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(),
          child: const JosaparRepresentantesApp(),
        ),
      );
      await tester.pumpAndSettle();
      // `AppShell` mantém o `SyncController` sempre observado em segundo
      // plano; sem um widget animando (spinner) durante o carregamento,
      // `pumpAndSettle` sozinho não garante tempo suficiente para os
      // `Future.delayed` internos do fake resolverem — um `pump` manual
      // avança o relógio fake de uma vez, evitando timers pendentes.
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Mais'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notificações'));
      await tester.pumpAndSettle();

      expect(find.text('Pedido Aprovado #8829'), findsOneWidget);
      expect(find.text('Urgente'), findsWidgets);

      await tester.tap(find.text('Não Lidas'));
      await tester.pumpAndSettle();
      expect(find.text('Pedido Aprovado #8829'), findsOneWidget);
      // "Atualização de Tabela de Preços" já nasce lida no fake — deve sumir no filtro de não lidas.
      expect(find.text('Atualização de Tabela de Preços'), findsNothing);

      await tester.tap(find.byIcon(Icons.done_all));
      await tester.pumpAndSettle();

      expect(find.text('Pedido Aprovado #8829'), findsNothing);
      expect(find.text('Nenhuma notificação encontrada.'), findsOneWidget);
    },
  );
}
