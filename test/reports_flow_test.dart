import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets('Fluxo de Relatórios: KPIs, gráficos e insight de vendas', (
    WidgetTester tester,
  ) async {
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
    await tester.tap(find.text('Relatórios & Indicadores'));
    await tester.pumpAndSettle();

    expect(find.text('R\$ 184.2K'), findsOneWidget);
    expect(find.text('VENDAS TOTAIS'), findsOneWidget);

    final reportsList = find.byType(ListView).last;

    for (final label in [
      'Tendência de Vendas',
      'Produtos Mais Vendidos',
      'Mix por Região',
      'Principais Clientes',
      'Insight de Vendas',
      'Agendar Visita',
    ]) {
      await tester.dragUntilVisible(
        find.text(label),
        reportsList,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(find.text(label), findsOneWidget);
    }
  });
}
