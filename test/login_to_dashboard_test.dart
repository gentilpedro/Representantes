import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/core/providers/core_providers.dart';
import 'package:josapar_representantes/core/services/connectivity_service.dart';
import 'package:josapar_representantes/features/auth/domain/entities/app_user.dart';
import 'package:josapar_representantes/features/auth/domain/repositories/auth_repository.dart';
import 'package:josapar_representantes/features/auth/presentation/providers/auth_providers.dart';
import 'package:josapar_representantes/main.dart';

/// `AppShell` mantém o `SyncController` sempre ativo, que checa
/// conectividade real via `connectivity_plus` — sem handler mockado isso
/// trava o teste, então sempre sobrescrevemos por uma versão "sempre
/// online, sem eventos" nos testes que passam pela tela principal.
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
  }) async {
    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Credenciais inválidas');
    }
    return _user;
  }

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets(
    'Login bem-sucedido navega até o Dashboard e mostra dados do representante',
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
      // `Future.delayed` internos do mock resolverem — um `pump` manual
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
