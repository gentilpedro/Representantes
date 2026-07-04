import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets('Fluxo de Perfil: dados do representante, permissões e logout', (
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
    await tester.tap(find.text('Perfil e Configurações'));
    await tester.pumpAndSettle();

    expect(find.text('Ricardo Santos'), findsOneWidget);
    expect(find.text('ID: #88294'), findsOneWidget);
    expect(find.textContaining('08:30'), findsOneWidget);
    expect(find.text('Vendas Offline'), findsOneWidget);
    expect(find.text('Aprovação de Crédito'), findsOneWidget);

    final logoutButton = find.text('Sair da Conta');
    await tester.dragUntilVisible(
      logoutButton,
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Logout leva à tela de Boas-vindas (novo ponto de entrada público),
    // não direto ao formulário de login.
    expect(find.text('Bem-vindo à Josapar'), findsOneWidget);
  });
}
