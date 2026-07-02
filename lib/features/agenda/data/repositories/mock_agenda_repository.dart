import '../../domain/entities/daily_route.dart';
import '../../domain/entities/scheduled_visit.dart';
import '../../domain/repositories/agenda_repository.dart';

/// Dados fixos espelhando a tela "Agenda de Visitas" do protótipo. Por ora
/// devolve sempre o mesmo roteiro de exemplo, independente da data
/// selecionada — a implementação real buscaria o roteiro do dia na API.
class MockAgendaRepository implements AgendaRepository {
  @override
  Future<DailyRoute> fetchDailyRoute(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 450));

    return const DailyRoute(
      totalKm: 42.5,
      estimatedDuration: '~1h 20min',
      visitsPlanned: 5,
      routeTip:
          'O trânsito na região do Porto está acima do normal. Considere '
          'utilizar a via auxiliar para chegar à próxima visita.',
      visits: [
        ScheduledVisit(
          id: 'v1',
          clientName: 'Supermercado Alvorada',
          scheduledTimeLabel: '08:30',
          address: 'Rua das Palmeiras, 450 - Centro, Pelotas - RS',
          status: VisitStatus.completed,
        ),
        ScheduledVisit(
          id: 'v2',
          clientName: 'Mercadinho do Bairro',
          scheduledTimeLabel: '10:00',
          address: 'Av. Bento Gonçalves, 1202 - Porto, Pelotas - RS',
          status: VisitStatus.inProgress,
          isGeoValidated: true,
        ),
        ScheduledVisit(
          id: 'v3',
          clientName: 'Rede de Postos Shell - Loja',
          scheduledTimeLabel: '11:30',
          address: 'BR-116, Km 524 - Zona Rural, Pelotas - RS',
          status: VisitStatus.pending,
        ),
        ScheduledVisit(
          id: 'v4',
          clientName: 'Atacado São Jorge',
          scheduledTimeLabel: '14:00',
          address: 'Rua Saturnino de Brito, 89 - Fragata, Pelotas - RS',
          status: VisitStatus.pending,
        ),
      ],
    );
  }
}
