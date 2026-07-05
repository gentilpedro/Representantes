import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Fluxo de Pedidos: lista, filtro, novo pedido, catálogo e adicionar ao carrinho',
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

      // Vai para a aba Pedidos.
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      expect(find.text('Meus Pedidos'), findsOneWidget);
      expect(find.text('Distribuidora Rio Grande'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Restaurante Central Buffet'), findsOneWidget);

      // Filtro "Pendentes" esconde os dois (um está sent, o outro error).
      await tester.tap(find.text('Pendentes'));
      await tester.pumpAndSettle();
      expect(find.text('Distribuidora Rio Grande'), findsNothing);
      expect(find.text('Restaurante Central Buffet'), findsNothing);
      expect(find.text('Nenhum pedido encontrado.'), findsOneWidget);

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      // Abre Novo Pedido pelo FAB — começa sem cliente/itens.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Novo Pedido'), findsOneWidget);
      expect(find.text('ITENS NO CARRINHO (0)'), findsOneWidget);

      // Seleciona um cliente pela lista real de Clientes.
      await tester.tap(find.text('Alterar'));
      await tester.pumpAndSettle();

      expect(find.text('Selecionar Cliente'), findsOneWidget);
      await tester.tap(find.text('Supermercado Silva & Filhos Ltda'));
      await tester.pumpAndSettle();

      expect(find.text('Novo Pedido'), findsOneWidget);
      expect(find.text('Supermercado Silva & Filhos Ltda'), findsOneWidget);

      // Vai para o catálogo e adiciona um produto ao pedido.
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Catálogo de Produtos'), findsOneWidget);
      expect(find.text('Arroz Integral Tipo 1 1kg'), findsOneWidget);

      await tester.tap(find.text('Arroz Integral Tipo 1 1kg'));
      await tester.pumpAndSettle();

      expect(find.text('ADICIONAR AO PEDIDO'), findsOneWidget);
      await tester.tap(find.text('ADICIONAR AO PEDIDO'));
      await tester.pumpAndSettle();

      // Voltou para o catálogo; volta mais uma vez para o pedido e confere o carrinho.
      expect(find.text('Catálogo de Produtos'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('ITENS NO CARRINHO (1)'), findsOneWidget);
    },
  );
}
