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
/// online, sem eventos". Este teste foca no botão manual "Sincronizar
/// Agora"; o reconector automático é coberto por `auto_sync_flow_test.dart`.
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
  testWidgets('Fluxo de Sincronização: status, conflito e "Sincronizar Agora"', (
    WidgetTester tester,
  ) async {
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
    await tester.tap(find.text('Sincronização'));
    await tester.pumpAndSettle();

    expect(find.text('Central de Dados'), findsOneWidget);
    // 1 pedido pending (#PED-9082, dado fixo do mock) + 2 itens de demonstração.
    expect(find.text('03'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('Conflito Detectado'), findsOneWidget);
    expect(find.text('Pedido #PED-9082'), findsOneWidget);

    await tester.tap(find.text('Sincronizar Agora'));
    await tester.pumpAndSettle();

    expect(find.text('00'), findsOneWidget);
    expect(find.text('131'), findsOneWidget);
    expect(find.text('Fila vazia. Tudo sincronizado!'), findsOneWidget);
    // Conflito exige resolução manual, não é limpo pela sincronização automática.
    expect(find.text('Conflito Detectado'), findsOneWidget);
  });
}
