import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets('Fluxo de Agenda: roteiro do dia, status das visitas e check-in', (
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
        matching: find.text('Agenda'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Agenda de Visitas'), findsOneWidget);
    expect(find.textContaining('42.5 km'), findsOneWidget);
    expect(find.text('2/5 Visitas'), findsOneWidget);
    expect(find.text('Supermercado Alvorada'), findsOneWidget);
    expect(find.text('Concluída'), findsOneWidget);
    expect(find.text('Em Andamento'), findsOneWidget);
    expect(
      find.text('Check-out'),
      findsOneWidget,
    ); // só a visita "Em Andamento" tem esse botão ainda.
    expect(
      find.text('Check-in'),
      findsNWidgets(2),
    ); // as duas visitas pendentes.

    // Faz check-in na primeira visita pendente ("Rede de Postos Shell - Loja").
    final checkInButton = find.text('Check-in').first;
    await tester.ensureVisible(checkInButton);
    await tester.pumpAndSettle();
    await tester.tap(checkInButton);
    await tester.pumpAndSettle();

    // Agora duas visitas têm botão "Check-out" (a que já estava em andamento + a recém check-in).
    expect(find.text('Check-out'), findsNWidgets(2));
    expect(find.text('Check-in'), findsOneWidget);
  });
}
