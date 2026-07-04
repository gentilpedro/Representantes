import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/fake_auth_repository.dart';
import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Primeiro Acesso: matrícula, requisitos de senha e retorno ao Login',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(authRepository: FakeAuthRepository.loggedOut()),
          child: const JosaparRepresentantesApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo à Josapar'), findsOneWidget);
      await tester.tap(find.text('Primeiro Acesso'));
      await tester.pumpAndSettle();

      expect(find.text('Primeiro Acesso'), findsWidgets);
      expect(find.text('Matrícula ou Identificador Único'), findsOneWidget);

      // "Continuar" começa desabilitado até preencher a matrícula.
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      await tester.enterText(find.byType(TextField), '00123456');
      await tester.pumpAndSettle();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Criar Senha'), findsWidgets);

      // "Salvar Senha" começa desabilitado.
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      // Senha fraca (só minúsculas): continua desabilitado.
      await tester.enterText(find.byType(TextField).first, 'fraca');
      await tester.pumpAndSettle();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      // Senha forte cumprindo todos os requisitos + confirmação igual.
      const strongPassword = 'Senha@123';
      await tester.enterText(find.byType(TextField).first, strongPassword);
      await tester.enterText(find.byType(TextField).last, strongPassword);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );

      await tester.tap(find.text('Salvar Senha'));
      await tester.pumpAndSettle();

      // Ativação bem-sucedida já devolve uma sessão autenticada — o redirect
      // do GoRouter leva direto ao Dashboard, sem passar pelo Login.
      expect(find.textContaining('Olá, Ricardo'), findsOneWidget);
    },
  );
}
