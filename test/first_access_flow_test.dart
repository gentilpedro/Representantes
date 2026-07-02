import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/core/providers/core_providers.dart';
import 'package:josapar_representantes/core/services/connectivity_service.dart';
import 'package:josapar_representantes/features/auth/domain/entities/app_user.dart';
import 'package:josapar_representantes/features/auth/domain/repositories/auth_repository.dart';
import 'package:josapar_representantes/features/auth/presentation/providers/auth_providers.dart';
import 'package:josapar_representantes/main.dart';

import 'support/hive_test_setup.dart';

class _FakeConnectivityService implements ConnectivityService {
  @override
  Future<bool> isOnline() async => true;

  @override
  Stream<bool> get onStatusChange => const Stream.empty();
}

class _FakeAuthRepository implements AuthRepository {
  static final _user = AppUser(
    id: '88294',
    name: 'Ricardo Santos',
    role: 'Representante Comercial Sênior',
    region: 'Região Sul',
    appVersion: 'v2.4.0',
  );

  @override
  Future<AppUser?> restoreSession() async => null;

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async => _user;

  @override
  Future<void> logout() async {}
}

void main() {
  setUpAll(() async {
    await setUpHiveForTest();
  });

  testWidgets(
    'Primeiro Acesso: matrícula, requisitos de senha e retorno ao Login',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
            connectivityServiceProvider.overrideWithValue(
              _FakeConnectivityService(),
            ),
          ],
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
      await tester.pump();
      // `_save` simula 900ms de latência antes do redirecionamento.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(
        find.text('Senha criada! Faça login para continuar.'),
        findsOneWidget,
      );
      expect(find.text('Acessar Sistema'), findsOneWidget);
    },
  );
}
