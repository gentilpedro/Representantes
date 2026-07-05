import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Fluxo de Leads: lista, filtro por status, criação e edição',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(),
          child: const JosaparRepresentantesApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Entra em Leads pelo Acesso Rápido do Dashboard (precisa rolar até lá).
      await tester.dragUntilVisible(
        find.text('Leads'),
        find.byType(ListView).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leads'));
      await tester.pumpAndSettle();

      expect(find.text('Mercearia do Bairro'), findsOneWidget);
      expect(find.text('Empório Boa Sorte'), findsOneWidget);

      // Filtro "Contatado" deve esconder o lead "Novo".
      await tester.tap(find.widgetWithText(ChoiceChip, 'Contatado'));
      await tester.pumpAndSettle();
      expect(find.text('Empório Boa Sorte'), findsOneWidget);
      expect(find.text('Mercearia do Bairro'), findsNothing);

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      // Cria um lead novo.
      await tester.tap(find.byIcon(Icons.person_add_alt_1_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Novo Lead'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'Fernanda Alves');
      await tester.enterText(find.byType(TextField).at(1), 'Padaria Estrela');
      await tester.enterText(find.byType(TextField).at(3), '(51) 99000-0000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Padaria Estrela'), findsOneWidget);
      // Deixa o SnackBar "Lead cadastrado." sumir — senão ele ainda ocupa o
      // `ScaffoldMessenger` quando tentarmos mostrar "Lead atualizado." mais
      // adiante, que fica em fila (invisível) atrás dele.
      await tester.pump(const Duration(seconds: 5));

      // Abre o detalhe do lead recém-criado.
      await tester.tap(find.text('Padaria Estrela'));
      await tester.pumpAndSettle();

      expect(find.text('Fernanda Alves'), findsOneWidget);
      expect(find.text('Novo'), findsOneWidget);

      // Edita e muda o status para "Contatado".
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Lead'), findsOneWidget);
      final statusChip = find.widgetWithText(ChoiceChip, 'Contatado');
      await tester.ensureVisible(statusChip);
      await tester.pumpAndSettle();
      await tester.tap(statusChip);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Lead atualizado.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));

      expect(
        find.text('Contatado'),
        findsOneWidget,
      );
    },
  );
}
