import 'dart:async';

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

/// Fake controlável: começa offline e permite simular a volta da conexão
/// através de [goOnline], disparando o listener de reconexão do
/// `SyncController` sem depender do plugin real `connectivity_plus`.
class _ControllableConnectivityService implements ConnectivityService {
  bool _isOnline = false;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => _isOnline;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  void goOnline() {
    _isOnline = true;
    _controller.add(true);
  }
}

void main() {
  setUpAll(() async {
    await setUpHiveForTest();
  });

  testWidgets(
    'Sincronização automática: pedido feito offline sincroniza sozinho ao '
    'reconectar; rascunho nunca entra na fila',
    (WidgetTester tester) async {
      final connectivity = _ControllableConnectivityService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _AlreadyLoggedInAuthRepository(),
            ),
            connectivityServiceProvider.overrideWithValue(connectivity),
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

      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      // Ainda offline: finaliza um pedido usando o carrinho pré-carregado.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();
      // `_finalizeOrder` agora também grava no Hive (I/O real de disco) e
      // não tem nenhum spinner visível durante a espera, então
      // `pumpAndSettle` sozinho pode não dar tempo suficiente — mesmo
      // padrão já visto no restante da suíte.
      await tester.pump(const Duration(seconds: 2));

      expect(
        find.text(
          'Pedido salvo localmente. Será sincronizado automaticamente '
          'quando a conexão voltar.',
        ),
        findsOneWidget,
      );
      // Deixa o SnackBar terminar sua animação e sumir (dura ~4s por
      // padrão) antes de continuar tocando na tela — enquanto ele ocupa a
      // parte de baixo da tela, o FAB some do lugar esperado pelo finder.
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.text('Pendentes'));
      await tester.pumpAndSettle();
      // #PED-9082 (dado fixo do mock) + o pedido recém-criado.
      expect(find.text('PENDENTE'), findsNWidgets(2));

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      // Ainda offline: adiciona um produto ao carrinho (agora vazio, pois
      // "Finalizar" limpa o carrinho) e salva como rascunho.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arroz Tio João Tipo 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADICIONAR AO PEDIDO'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Salvar rascunho'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.text('Rascunhos'));
      await tester.pumpAndSettle();
      // #PED-8940 (dado fixo do mock) + o rascunho recém-criado.
      expect(find.text('RASCUNHO'), findsNWidgets(2));

      // Reconecta: a sincronização deve disparar sozinha, sem tocar em
      // "Sincronizar Agora" em lugar nenhum. Como nada na tela de Pedidos
      // anima durante o `syncNow()` em segundo plano, um `pump` manual
      // garante tempo suficiente para os `Future.delayed` do mock antes do
      // `pumpAndSettle` final.
      connectivity.goOnline();
      // syncPendingOrders (~400ms) + MockSyncRepository.syncNow (~1s) +
      // o refetch de ordersListProvider disparado pela invalidação (~500ms)
      // rodam em sequência — dá folga generosa para tudo isso resolver.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pendentes'));
      await tester.pumpAndSettle();
      // Sem nenhum pedido pending sobrando, o filtro "Pendentes" fica
      // vazio — prova de que a sincronização automática já rodou e moveu
      // os 2 pedidos pendentes (offline) para "sent" sozinha.
      expect(find.text('Nenhum pedido encontrado.'), findsOneWidget);

      // Os rascunhos não foram tocados pela sincronização automática.
      await tester.tap(find.text('Rascunhos'));
      await tester.pumpAndSettle();
      expect(find.text('RASCUNHO'), findsNWidgets(2));
    },
  );
}
