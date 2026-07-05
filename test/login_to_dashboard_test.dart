import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/fake_auth_repository.dart';
import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Login bem-sucedido navega até o Dashboard e mostra dados do representante',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(authRepository: FakeAuthRepository.loggedOut()),
          child: const JosaparRepresentantesApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tela de Boas-vindas é o novo ponto de entrada público; "Entrar"
      // leva ao formulário de login de sempre.
      expect(find.text('Bem-vindo à Josapar'), findsOneWidget);
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Acessar Sistema'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '88294');
      await tester.enterText(find.byType(TextField).last, 'senha123');
      await tester.tap(find.text('Acessar Sistema'));
      await tester.pumpAndSettle();
      // `AppShell` mantém o `SyncController` sempre observado em segundo
      // plano; sem um widget animando (spinner) durante o carregamento,
      // `pumpAndSettle` sozinho não garante tempo suficiente para os
      // `Future.delayed` internos do fake resolverem — um `pump` manual
      // avança o relógio fake de uma vez, evitando timers pendentes.
      await tester.pump(const Duration(seconds: 2));

      expect(find.textContaining('Olá, Ricardo'), findsOneWidget);
      expect(find.text('Acesso Rápido'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Meta Mensal'), findsOneWidget);
    },
  );
}
