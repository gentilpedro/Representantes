import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/core/providers/core_providers.dart';
import 'package:josapar_representantes/core/services/connectivity_service.dart';
import 'package:josapar_representantes/features/agenda/data/services/location_service.dart';
import 'package:josapar_representantes/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:josapar_representantes/features/auth/domain/entities/app_user.dart';
import 'package:josapar_representantes/features/auth/domain/repositories/auth_repository.dart';
import 'package:josapar_representantes/features/auth/presentation/providers/auth_providers.dart';
import 'package:josapar_representantes/main.dart';

import 'support/hive_test_setup.dart';

/// A instância real usa o plugin `geolocator`, que trava esperando resposta
/// de platform channel em ambiente de teste (sem handler mockado). Nos
/// testes, sobrescrevemos por uma implementação que resolve na hora — o
/// mesmo padrão usado para o repositório de autenticação.
class _FakeLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentPosition() async {
    return const LocationResult(
      errorMessage: 'GPS indisponível neste ambiente de teste.',
    );
  }
}

/// `AppShell` mantém o `SyncController` sempre ativo, que checa
/// conectividade real via `connectivity_plus` — mesmo problema de platform
/// channel do `geolocator` acima, mesma solução.
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

  testWidgets('Fluxo de Agenda: roteiro do dia, status das visitas e check-in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _AlreadyLoggedInAuthRepository(),
          ),
          locationServiceProvider.overrideWithValue(_FakeLocationService()),
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
        matching: find.text('Agenda'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Agenda de Visitas'), findsOneWidget);
    expect(find.textContaining('42.5 km'), findsOneWidget);
    expect(find.text('2/5 Visitas'), findsOneWidget);
    expect(find.text('Supermercado Alvorada'), findsOneWidget);
    expect(find.text('Concluída'), findsOneWidget);
    expect(find.text('Em Andamento'), findsOneWidget);
    expect(
      find.text('Check-out'),
      findsOneWidget,
    ); // só a visita "Em Andamento" tem esse botão ainda.
    expect(
      find.text('Check-in'),
      findsNWidgets(3),
    ); // as duas visitas pendentes + a parada de lead (também pending).
    // A parada vinda de `LeadsRepository` aparece com o chip de potencial.
    expect(find.text('Cliente em Potencial'), findsOneWidget);

    // Faz check-in na primeira visita pendente ("Rede de Postos Shell - Loja").
    final checkInButton = find.text('Check-in').first;
    await tester.ensureVisible(checkInButton);
    await tester.pumpAndSettle();
    await tester.tap(checkInButton);
    await tester.pumpAndSettle();

    // Agora duas visitas têm botão "Check-out" (a que já estava em andamento + a recém check-in).
    expect(find.text('Check-out'), findsNWidgets(2));
    expect(find.text('Check-in'), findsNWidgets(2));
  });
}
