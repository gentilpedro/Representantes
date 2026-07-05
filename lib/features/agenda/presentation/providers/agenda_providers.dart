import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/api_agenda_repository.dart';
import '../../data/services/location_service.dart';
import '../../domain/entities/daily_route.dart';
import '../../domain/repositories/agenda_repository.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

final agendaRepositoryProvider = Provider<AgendaRepository>(
  (ref) => ApiAgendaRepository(ref.watch(apiClientProvider)),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final selectedAgendaDateProvider = StateProvider<DateTime>(
  (ref) => _dateOnly(DateTime.now()),
);

class AgendaController extends AsyncNotifier<DailyRoute> {
  @override
  Future<DailyRoute> build() async {
    final date = ref.watch(selectedAgendaDateProvider);
    return ref.watch(agendaRepositoryProvider).fetchDailyRoute(date);
  }

  Future<void> checkIn(String visitId, {double? latitude, double? longitude}) async {
    await ref
        .read(agendaRepositoryProvider)
        .checkIn(visitId, latitude: latitude, longitude: longitude);
    ref.invalidateSelf();
    await future;
  }

  Future<void> checkOut(String visitId, String notes) async {
    await ref.read(agendaRepositoryProvider).checkOut(visitId, notes);
    ref.invalidateSelf();
    await future;
  }

  Future<void> createVisit({
    required String clientId,
    required DateTime scheduledAtUtc,
    String? notes,
  }) async {
    await ref.read(agendaRepositoryProvider).createVisit(
      clientId: clientId,
      scheduledAtUtc: scheduledAtUtc,
      notes: notes,
    );
    ref.invalidateSelf();
    await future;
  }
}

final agendaControllerProvider =
    AsyncNotifierProvider<AgendaController, DailyRoute>(AgendaController.new);
