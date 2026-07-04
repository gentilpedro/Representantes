import 'package:josapar_representantes/features/agenda/domain/entities/daily_route.dart';
import 'package:josapar_representantes/features/agenda/domain/entities/scheduled_visit.dart';
import 'package:josapar_representantes/features/agenda/domain/repositories/agenda_repository.dart';

class FakeAgendaRepository implements AgendaRepository {
  FakeAgendaRepository() : _visits = {for (final v in _seedVisits) v.id: v};

  static const _seedVisits = <ScheduledVisit>[
    ScheduledVisit(
      id: 'v1',
      clientName: 'Supermercado Alvorada',
      scheduledTimeLabel: '08:30',
      address: 'Rua das Flores, 100 - Porto Alegre/RS',
      status: VisitStatus.completed,
      notes: 'Reposição mensal confirmada.',
      isGeoValidated: true,
    ),
    ScheduledVisit(
      id: 'v2',
      clientName: 'Padaria Bom Gosto',
      scheduledTimeLabel: '10:00',
      address: 'Av. Central, 200 - Porto Alegre/RS',
      status: VisitStatus.inProgress,
      isGeoValidated: true,
    ),
    ScheduledVisit(
      id: 'v3',
      clientName: 'Rede de Postos Shell - Loja',
      scheduledTimeLabel: '13:00',
      address: 'Av. Brasil, 300 - Canoas/RS',
      status: VisitStatus.pending,
    ),
    ScheduledVisit(
      id: 'v4',
      clientName: 'Mercado Vila Nova',
      scheduledTimeLabel: '15:30',
      address: 'Rua Nova, 400 - Canoas/RS',
      status: VisitStatus.pending,
    ),
  ];

  final Map<String, ScheduledVisit> _visits;

  @override
  Future<DailyRoute> fetchDailyRoute(DateTime date) async {
    return DailyRoute(
      totalKm: 42.5,
      estimatedDuration: '~1h 20min',
      visitsPlanned: 5,
      routeTip: 'Evite a Av. Central entre 12h-14h por conta de obras.',
      visits: _visits.values.toList(),
    );
  }

  @override
  Future<void> checkIn(String visitId, {double? latitude, double? longitude}) async {
    final visit = _visits[visitId];
    if (visit == null) return;
    _visits[visitId] = visit.copyWith(
      status: VisitStatus.inProgress,
      isGeoValidated: latitude != null && longitude != null,
    );
  }

  @override
  Future<void> checkOut(String visitId, String notes) async {
    final visit = _visits[visitId];
    if (visit == null) return;
    _visits[visitId] = visit.copyWith(status: VisitStatus.completed, notes: notes);
  }
}
