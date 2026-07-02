import 'scheduled_visit.dart';

class DailyRoute {
  const DailyRoute({
    required this.totalKm,
    required this.estimatedDuration,
    required this.visits,
    required this.visitsPlanned,
    this.routeTip,
  });

  final double totalKm;
  final String estimatedDuration;
  final List<ScheduledVisit> visits;

  /// Total de visitas planejadas para o dia (pode ser maior que
  /// [visits].length se algumas ainda não tiverem sido carregadas em
  /// detalhe — mantido separado para refletir o "X/Y visitas" do roteiro).
  final int visitsPlanned;

  final String? routeTip;

  int get completedOrInProgressCount => visits
      .where(
        (v) =>
            v.status == VisitStatus.completed ||
            v.status == VisitStatus.inProgress,
      )
      .length;
}
