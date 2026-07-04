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

      // Volta pra lista e cadastra um cliente novo pelo FAB.
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_add_alt_1_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Novo Cliente'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'Empório Nova Era');
      await tester.enterText(find.byType(TextField).at(1), '11.222.333/0001-44');
      await tester.enterText(find.byType(TextField).at(2), '(51) 3000-1111');
      await tester.enterText(find.byType(TextField).at(3), '(51) 99000-1111');
      await tester.enterText(
        find.byType(TextField).at(4),
        'contato@emporionovaera.example.com',
      );
      await tester.enterText(find.byType(TextField).at(6), 'Rua Nova, 10');
      await tester.enterText(find.byType(TextField).at(8), 'Porto Alegre');
      await tester.enterText(find.byType(TextField).at(9), 'RS');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Empório Nova Era'),
        find.byType(ListView).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(find.text('Empório Nova Era'), findsOneWidget);
    },
  );
}
