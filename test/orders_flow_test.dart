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
  testWidgets(
    'Fluxo de Pedidos: lista, filtro, novo pedido, catálogo e adicionar ao carrinho',
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

      // Vai para a aba Pedidos.
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      expect(find.text('Meus Pedidos'), findsOneWidget);
      expect(find.text('Supermercado Silva & Filhos Ltda'), findsOneWidget);

      // Rola até o histórico para confirmar que o pedido com erro está na lista completa.
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Restaurante Central Buffet'), findsOneWidget);

      // Filtro "Pendentes" deve esconder o pedido com erro.
      await tester.tap(find.text('Pendentes'));
      await tester.pumpAndSettle();
      expect(find.text('Supermercado Silva & Filhos Ltda'), findsOneWidget);
      expect(find.text('Restaurante Central Buffet'), findsNothing);

      // Abre Novo Pedido pelo FAB.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Novo Pedido'), findsOneWidget);
      expect(find.text('ITENS NO CARRINHO (2)'), findsOneWidget);

      // Vai para o catálogo e adiciona um produto ao pedido.
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Catálogo de Produtos'), findsOneWidget);
      expect(find.text('Arroz Tio João Tipo 1'), findsOneWidget);

      await tester.tap(find.text('Arroz Tio João Tipo 1'));
      await tester.pumpAndSettle();

      expect(find.text('ADICIONAR AO PEDIDO'), findsOneWidget);
      await tester.tap(find.text('ADICIONAR AO PEDIDO'));
      await tester.pumpAndSettle();

      // Voltou para o catálogo; volta mais uma vez para o pedido e confere o carrinho.
      expect(find.text('Catálogo de Produtos'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('ITENS NO CARRINHO (3)'), findsOneWidget);

      // Troca o cliente selecionado pela lista real de Clientes.
      expect(find.text('Supermercado Silva & Filhos Ltda'), findsOneWidget);
      await tester.tap(find.text('Alterar'));
      await tester.pumpAndSettle();

      expect(find.text('Selecionar Cliente'), findsOneWidget);
      await tester.tap(find.text('Supermercados Alvorada Ltda'));
      await tester.pumpAndSettle();

      expect(find.text('Novo Pedido'), findsOneWidget);
      expect(find.text('Supermercados Alvorada Ltda'), findsOneWidget);
      expect(find.text('Supermercado Silva & Filhos Ltda'), findsNothing);
    },
  );
}
