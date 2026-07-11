import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Favoritar um cliente pela lista atualiza o ícone e aparece no filtro Favoritos',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(),
          child: const JosaparRepresentantesApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Clientes'),
        ),
      );
      await tester.pumpAndSettle();

      // "Atacado Boa Vista" (c2) não é favorito no seed.
      expect(find.text('Atacado Boa Vista'), findsOneWidget);

      final starButton = find.descendant(
        of: find.ancestor(
          of: find.text('Atacado Boa Vista'),
          matching: find.byType(Card),
        ),
        matching: find.byIcon(Icons.star_border),
      );
      expect(starButton, findsOneWidget);

      await tester.tap(starButton);
      await tester.pumpAndSettle();

      // Ícone virou estrela preenchida.
      final filledStar = find.descendant(
        of: find.ancestor(
          of: find.text('Atacado Boa Vista'),
          matching: find.byType(Card),
        ),
        matching: find.byIcon(Icons.star),
      );
      expect(filledStar, findsOneWidget);

      // E aparece no filtro "Favoritos".
      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('Atacado Boa Vista'), findsOneWidget);
    },
  );
}
