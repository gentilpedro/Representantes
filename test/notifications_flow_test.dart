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

class _AlreadyLoggedInAuthRepository implements AuthRepository {
  static final _user = AppUser(
    id: '88294',
    name: 'Ricardo Santos',
    role: 'Representante Comercial Sênior',
    region: 'Região Sul',
    appVersion: 'v2.4.0',
  );

  @override
  Future<AppUser?> restoreSession() async => _user;

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
    'Fluxo de Notificações: lista, filtro de não lidas e marcar todas como lidas',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _AlreadyLoggedInAuthRepository(),
            ),
            connectivityServiceProvider.overrideWithValue(
              _FakeConnectivityService(),
            ),
          ],
          child: const JosaparRepresentantesApp(),
        ),
      );
      await tester.pumpAndSettle();
      // `AppShell` mantém o `SyncController` sempre observado em segundo
      // plano; sem um widget animando (spinner) durante o carregamento,
      // `pumpAndSettle` sozinho não garante tempo suficiente para os
      // `Future.delayed` internos do mock resolverem — um `pump` manual
      // avança o relógio fake de uma vez, evitando timers pendentes.
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Mais'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notificações'));
      await tester.pumpAndSettle();

      expect(find.text('Pedido Aprovado #8829'), findsOneWidget);
      expect(find.text('Urgente'), findsWidgets);

      await tester.tap(find.text('Não Lidas'));
      await tester.pumpAndSettle();
      expect(find.text('Pedido Aprovado #8829'), findsOneWidget);
      // "Atualização de Tabela de Preços" já nasce lida no mock — deve sumir no filtro de não lidas.
      expect(find.text('Atualização de Tabela de Preços'), findsNothing);

      await tester.tap(find.byIcon(Icons.done_all));
      await tester.pumpAndSettle();

      expect(find.text('Pedido Aprovado #8829'), findsNothing);
      expect(find.text('Nenhuma notificação encontrada.'), findsOneWidget);
    },
  );
}
