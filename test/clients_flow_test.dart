import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Fluxo de Clientes: lista, filtro de favoritos e detalhe financeiro',
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
          matching: find.text('Clientes'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Supermercado Silva & Filhos Ltda'), findsOneWidget);

      final clientsList = find.byType(ListView).first;
      await tester.dragUntilVisible(
        find.text('Mercearia do Canto - Unidade'),
        clientsList,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mercearia do Canto - Unidade'), findsOneWidget);

      // Filtro "Favoritos" deve esconder clientes não favoritados.
      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(find.text('Supermercado Silva & Filhos Ltda'), findsOneWidget);
      expect(find.text('Mercearia do Canto - Unidade'), findsNothing);

      await tester.tap(find.text('Supermercado Silva & Filhos Ltda'));
      await tester.pumpAndSettle();

      expect(find.text('Resumo Financeiro'), findsOneWidget);
      expect(find.text('1 Fatura Vencendo'), findsOneWidget);
      expect(find.textContaining('CLI-88291'), findsOneWidget);
    },
  );
}
