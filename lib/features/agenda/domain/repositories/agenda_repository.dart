import '../entities/daily_route.dart';

/// Contrato da agenda, contra `GET /api/agenda?date=...` e
/// `POST /api/visits/{id}/check-in|check-out` da Web API .NET 10.
abstract class AgendaRepository {
  Future<DailyRoute> fetchDailyRoute(DateTime date);

  /// [date] é o dia da agenda sendo visualizado (não precisa ser hoje) —
  /// usado só pra saber qual cache local atualizar quando offline, já que
  /// o cache é guardado por dia.
  Future<void> checkIn(
    String visitId,
    DateTime date, {
    double? latitude,
    double? longitude,
  });

  Future<void> checkOut(String visitId, DateTime date, String notes);

  Future<void> createVisit({
    required String clientId,
    required DateTime scheduledAtUtc,
    String? notes,
  });
}
