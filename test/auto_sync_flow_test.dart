import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/features/orders/domain/entities/order_summary.dart';
import 'package:josapar_representantes/main.dart';

import 'fakes/fake_connectivity_service.dart';
import 'fakes/fake_orders_repository.dart';
import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Sincronização automática: pedido feito offline sincroniza sozinho ao '
    'reconectar; rascunho nunca entra na fila',
    (WidgetTester tester) async {
      final connectivity = FakeConnectivityService(isOnline: false);
      // Um rascunho pré-existente, pra confirmar que a sincronização
      // automática nunca toca nele.
      final orders = FakeOrdersRepository(
        seed: const [
          OrderSummary(
            id: 'o1',
            code: '#PED-8940',
            clientName: 'Restaurante Central Buffet',
            dateLabel: 'Ontem',
            itemsCount: 5,
            total: 812.10,
            status: OrderStatus.draft,
            isToday: false,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(
            connectivityService: connectivity,
            ordersRepository: orders,
          ),
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

      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      // Ainda offline: seleciona cliente, adiciona produto e finaliza.
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
      await tester.pageBack();
      await tester.pumpAndSettle();
      // Deixa o SnackBar de "adicionado ao pedido" sumir — senão ele ainda
      // ocupa o `ScaffoldMessenger` quando `_finalizeOrder` tenta mostrar o
      // seu próprio SnackBar, que fica em fila (invisível) atrás do
      // primeiro em vez de aparecer na hora.
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Pedido salvo localmente. Será sincronizado automaticamente '
          'quando a conexão voltar.',
        ),
        findsOneWidget,
      );
      // Deixa o SnackBar terminar sua animação e sumir (dura ~4s por
      // padrão) antes de continuar tocando na tela — enquanto ele ocupa a
      // parte de baixo da tela, o FAB some do lugar esperado pelo finder.
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.text('Pendentes'));
      await tester.pumpAndSettle();
      expect(find.text('PENDENTE'), findsOneWidget);

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      // Ainda offline: novo pedido, mesmo cliente, mesmo produto, mas salvo
      // como rascunho — rascunhos nunca entram na fila de sincronização.
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
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Salvar rascunho'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.text('Rascunhos'));
      await tester.pumpAndSettle();
      // O rascunho pré-existente + o recém-criado.
      expect(find.text('RASCUNHO'), findsNWidgets(2));

      // Reconecta: a sincronização deve disparar sozinha, sem tocar em
      // "Sincronizar Agora" em lugar nenhum. Como nada na tela de Pedidos
      // anima durante o `syncNow()` em segundo plano, um `pump` manual
      // garante tempo suficiente para os `Future.delayed` do fake antes do
      // `pumpAndSettle` final.
      connectivity.goOnline();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pendentes'));
      await tester.pumpAndSettle();
      // Sem nenhum pedido pending sobrando, o filtro "Pendentes" fica
      // vazio — prova de que a sincronização automática já rodou e moveu
      // o pedido pendente (offline) para "sent" sozinha.
      expect(find.text('Nenhum pedido encontrado.'), findsOneWidget);

      // Os rascunhos não foram tocados pela sincronização automática.
      await tester.tap(find.text('Rascunhos'));
      await tester.pumpAndSettle();
      expect(find.text('RASCUNHO'), findsNWidgets(2));
    },
  );
}
