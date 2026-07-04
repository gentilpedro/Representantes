import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/features/orders/domain/entities/order_summary.dart';
import 'package:josapar_representantes/features/sync/domain/entities/sync_summary.dart';
import 'package:josapar_representantes/main.dart';

import 'fakes/fake_orders_repository.dart';
import 'fakes/fake_sync_repository.dart';
import 'fakes/test_overrides.dart';

void main() {
  testWidgets('Fluxo de Sincronização: status, conflito e "Sincronizar Agora"', (
    WidgetTester tester,
  ) async {
    // 2 pedidos pending (fila local aguardando envio) + 3 já sent.
    final orders = FakeOrdersRepository(
      seed: const [
        OrderSummary(
          id: 'o1',
          code: '#PED-9082',
          clientName: 'Distribuidora Rio Grande',
          dateLabel: 'Hoje, 10:45',
          itemsCount: 3,
          total: 452.30,
          status: OrderStatus.pending,
          isToday: true,
        ),
        OrderSummary(
          id: 'o2',
          code: '#PED-9083',
          clientName: 'Padaria Central',
          dateLabel: 'Hoje, 11:20',
          itemsCount: 1,
          total: 88.00,
          status: OrderStatus.pending,
          isToday: true,
        ),
        OrderSummary(
          id: 'o3',
          code: '#PED-8940',
          clientName: 'Restaurante Central Buffet',
          dateLabel: 'Ontem',
          itemsCount: 5,
          total: 812.10,
          status: OrderStatus.sent,
          isToday: false,
        ),
        OrderSummary(
          id: 'o4',
          code: '#PED-8801',
          clientName: 'Mercado Vila Nova',
          dateLabel: '2 dias atrás',
          itemsCount: 2,
          total: 210.00,
          status: OrderStatus.sent,
          isToday: false,
        ),
        OrderSummary(
          id: 'o5',
          code: '#PED-8790',
          clientName: 'Armazém Central',
          dateLabel: '3 dias atrás',
          itemsCount: 4,
          total: 305.00,
          status: OrderStatus.sent,
          isToday: false,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(
          ordersRepository: orders,
          syncRepository: FakeSyncRepository(
            ordersRepository: orders,
            conflict: const SyncConflict(
              orderCode: '#PED-9070',
              clientName: 'Supermercado Silva & Filhos Ltda',
              reason: 'Limite de crédito excedido no ERP.',
            ),
          ),
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

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Mais'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sincronização'));
    await tester.pumpAndSettle();

    expect(find.text('Central de Dados'), findsOneWidget);
    // 2 pedidos pending na fila local.
    expect(find.text('02'), findsOneWidget);
    // 3 pedidos já sent.
    expect(find.text('03'), findsOneWidget);
    expect(find.text('Conflito Detectado'), findsOneWidget);
    expect(find.text('Pedido #PED-9082'), findsOneWidget);

    await tester.tap(find.text('Sincronizar Agora'));
    await tester.pumpAndSettle();

    expect(find.text('00'), findsOneWidget);
    expect(find.text('05'), findsOneWidget);
    expect(find.text('Fila vazia. Tudo sincronizado!'), findsOneWidget);
    // Conflito exige resolução manual, não é limpo pela sincronização.
    expect(find.text('Conflito Detectado'), findsOneWidget);
  });
}
