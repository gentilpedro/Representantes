import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/features/profile/presentation/providers/profile_providers.dart';
import 'package:josapar_representantes/main.dart';

import 'fakes/test_overrides.dart';

void main() {
  testWidgets(
    'Foto de perfil escolhida substitui o ícone padrão no avatar',
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
          matching: find.text('Mais'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Perfil e Configurações'));
      await tester.pumpAndSettle();

      // Sem foto: mostra o ícone de pessoa padrão.
      expect(find.byIcon(Icons.person), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byIcon(Icons.person)),
      );
      await container
          .read(profilePhotoProvider.notifier)
          .setPhoto('assets/branding/app_icon.png');
      await tester.pumpAndSettle();

      // Com foto: o ícone padrão some (o avatar usa `FileImage`).
      expect(find.byIcon(Icons.person), findsNothing);
    },
  );
}
