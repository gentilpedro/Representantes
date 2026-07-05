import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:josapar_representantes/core/providers/core_providers.dart';
import 'package:josapar_representantes/core/services/connectivity_service.dart';
import 'package:josapar_representantes/features/agenda/data/services/location_service.dart';
import 'package:josapar_representantes/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:josapar_representantes/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:josapar_representantes/features/auth/domain/repositories/auth_repository.dart';
import 'package:josapar_representantes/features/auth/presentation/providers/auth_providers.dart';
import 'package:josapar_representantes/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:josapar_representantes/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:josapar_representantes/features/clients/domain/repositories/clients_repository.dart';
import 'package:josapar_representantes/features/clients/presentation/providers/clients_providers.dart';
import 'package:josapar_representantes/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:josapar_representantes/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:josapar_representantes/features/leads/domain/repositories/leads_repository.dart';
import 'package:josapar_representantes/features/leads/presentation/providers/leads_providers.dart';
import 'package:josapar_representantes/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:josapar_representantes/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:josapar_representantes/features/orders/domain/repositories/orders_repository.dart';
import 'package:josapar_representantes/features/orders/presentation/providers/orders_providers.dart';
import 'package:josapar_representantes/features/profile/domain/repositories/profile_repository.dart';
import 'package:josapar_representantes/features/profile/presentation/providers/profile_providers.dart';
import 'package:josapar_representantes/features/reports/domain/repositories/reports_repository.dart';
import 'package:josapar_representantes/features/reports/presentation/providers/reports_providers.dart';
import 'package:josapar_representantes/features/sync/domain/repositories/sync_repository.dart';
import 'package:josapar_representantes/features/sync/presentation/providers/sync_providers.dart';

import 'fake_agenda_repository.dart';
import 'fake_auth_repository.dart';
import 'fake_catalog_repository.dart';
import 'fake_clients_repository.dart';
import 'fake_connectivity_service.dart';
import 'fake_dashboard_repository.dart';
import 'fake_leads_repository.dart';
import 'fake_location_service.dart';
import 'fake_notifications_repository.dart';
import 'fake_orders_repository.dart';
import 'fake_profile_repository.dart';
import 'fake_reports_repository.dart';
import 'fake_sync_repository.dart';

/// Overrides padrão pra qualquer teste que monte o app inteiro
/// (`JosaparRepresentantesApp`) — `AppShell` mantém o `SyncController`
/// sempre observado, que por sua vez depende de Orders + Sync + a
/// conectividade, então TODO teste de fluxo completo precisa desses
/// overrides, não só do que a tela em questão usa diretamente.
///
/// Cada parâmetro é opcional: passe uma instância própria pra sobrescrever
/// só o que aquele teste precisa customizar (ex: uma `OrdersRepository` com
/// uma fila pendente específica), mantendo os fakes padrão pro resto.
List<Override> testOverrides({
  AuthRepository? authRepository,
  ConnectivityService? connectivityService,
  CatalogRepository? catalogRepository,
  ClientsRepository? clientsRepository,
  OrdersRepository? ordersRepository,
  AgendaRepository? agendaRepository,
  DashboardRepository? dashboardRepository,
  ReportsRepository? reportsRepository,
  NotificationsRepository? notificationsRepository,
  ProfileRepository? profileRepository,
  SyncRepository? syncRepository,
  LocationService? locationService,
  LeadsRepository? leadsRepository,
}) {
  final orders = ordersRepository ?? FakeOrdersRepository();

  return [
    authRepositoryProvider.overrideWithValue(
      authRepository ?? FakeAuthRepository.loggedIn(),
    ),
    connectivityServiceProvider.overrideWithValue(
      connectivityService ?? FakeConnectivityService(),
    ),
    catalogRepositoryProvider.overrideWithValue(
      catalogRepository ?? FakeCatalogRepository(),
    ),
    clientsRepositoryProvider.overrideWithValue(
      clientsRepository ?? FakeClientsRepository(),
    ),
    ordersRepositoryProvider.overrideWithValue(orders),
    agendaRepositoryProvider.overrideWithValue(
      agendaRepository ?? FakeAgendaRepository(),
    ),
    dashboardRepositoryProvider.overrideWithValue(
      dashboardRepository ?? FakeDashboardRepository(),
    ),
    reportsRepositoryProvider.overrideWithValue(
      reportsRepository ?? FakeReportsRepository(),
    ),
    notificationsRepositoryProvider.overrideWithValue(
      notificationsRepository ?? FakeNotificationsRepository(),
    ),
    profileRepositoryProvider.overrideWithValue(
      profileRepository ?? FakeProfileRepository(),
    ),
    syncRepositoryProvider.overrideWithValue(
      syncRepository ?? FakeSyncRepository(ordersRepository: orders),
    ),
    locationServiceProvider.overrideWithValue(
      locationService ?? FakeLocationService(),
    ),
    leadsRepositoryProvider.overrideWithValue(
      leadsRepository ?? FakeLeadsRepository(),
    ),
  ];
}
