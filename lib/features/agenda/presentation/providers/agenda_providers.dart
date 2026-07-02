import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_agenda_repository.dart';
import '../../data/services/location_service.dart';
import '../../domain/entities/daily_route.dart';
import '../../domain/entities/scheduled_visit.dart';
import '../../domain/repositories/agenda_repository.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

final agendaRepositoryProvider = Provider<AgendaRepository>(
  (ref) => MockAgendaRepository(),
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

  void checkIn(String visitId, {required bool geoValidated}) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      _updateVisit(
        current,
        visitId,
        (v) => v.copyWith(
          status: VisitStatus.inProgress,
          isGeoValidated: geoValidated,
        ),
      ),
    );
  }

  void checkOut(String visitId, String notes) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      _updateVisit(
        current,
        visitId,
        (v) => v.copyWith(status: VisitStatus.completed, notes: notes),
      ),
    );
  }

  void updateNotes(String visitId, String notes) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      _updateVisit(current, visitId, (v) => v.copyWith(notes: notes)),
    );
  }

  DailyRoute _updateVisit(
    DailyRoute route,
    String visitId,
    ScheduledVisit Function(ScheduledVisit) update,
  ) {
    return DailyRoute(
      totalKm: route.totalKm,
      estimatedDuration: route.estimatedDuration,
      visitsPlanned: route.visitsPlanned,
      routeTip: route.routeTip,
      visits: [
        for (final visit in route.visits)
          if (visit.id == visitId) update(visit) else visit,
      ],
    );
  }
}

final agendaControllerProvider =
    AsyncNotifierProvider<AgendaController, DailyRoute>(AgendaController.new);
