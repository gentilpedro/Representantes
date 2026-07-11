import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

Future<void> _openNewOrderWithOneCartItem(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(overrides: testOverrides(), child: const JosaparRepresentantesApp()),
  );
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2));

  await tester.tap(find.text('Pedidos'));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Alterar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Supermercado Silva & Filhos Ltda'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Adicionar'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Arroz Integral Tipo 1 1kg'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ADICIONAR AO PEDIDO'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Ícone do carrinho no Catálogo volta pro mesmo Novo Pedido, sem duplicar a tela',
    (WidgetTester tester) async {
      await _openNewOrderWithOneCartItem(tester);

      // Depois de adicionar, volta pro Catálogo (não direto pro pedido).
      expect(find.text('Catálogo de Produtos'), findsOneWidget);

      // Usa o ícone do carrinho (não a seta de voltar) pra retornar ao pedido.
      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Novo Pedido'), findsOneWidget);
      expect(find.text('ITENS NO CARRINHO (1)'), findsOneWidget);

      // Descarta o pedido: se o ícone do carrinho tivesse empurrado uma
      // segunda tela de "Novo Pedido" (o bug), esse "Cancelar" só sairia da
      // instância duplicada, caindo de volta no Catálogo em vez da lista de
      // Pedidos.
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();

      expect(find.text('Meus Pedidos'), findsOneWidget);
      expect(find.text('Catálogo de Produtos'), findsNothing);
    },
  );

  testWidgets(
    'Cancelar com itens no carrinho pergunta antes de sair; "Continuar editando" mantém o pedido',
    (WidgetTester tester) async {
      await _openNewOrderWithOneCartItem(tester);
      await tester.pageBack(); // volta do Catálogo pro Novo Pedido
      await tester.pumpAndSettle();

      expect(find.text('ITENS NO CARRINHO (1)'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Sair do pedido?'), findsOneWidget);

      await tester.tap(find.text('Continuar editando'));
      await tester.pumpAndSettle();

      // Diálogo fechado, ainda no pedido, item preservado.
      expect(find.text('Novo Pedido'), findsOneWidget);
      expect(find.text('ITENS NO CARRINHO (1)'), findsOneWidget);

      // "Salvar rascunho" finaliza como rascunho e sai sem novo aviso.
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar rascunho'));
      await tester.pumpAndSettle();

      expect(find.text('Meus Pedidos'), findsOneWidget);
    },
  );

  testWidgets(
    'Cancelar sem itens no carrinho sai direto, sem perguntar nada',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(),
          child: const JosaparRepresentantesApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('ITENS NO CARRINHO (0)'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Sair do pedido?'), findsNothing);
      expect(find.text('Meus Pedidos'), findsOneWidget);
    },
  );
}
