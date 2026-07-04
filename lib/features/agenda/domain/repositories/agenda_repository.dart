import '../entities/daily_route.dart';

/// Contrato da agenda, contra `GET /api/agenda?date=...` e
/// `POST /api/visits/{id}/check-in|check-out` da Web API .NET 10.
abstract class AgendaRepository {
  Future<DailyRoute> fetchDailyRoute(DateTime date);

  Future<void> checkIn(String visitId, {double? latitude, double? longitude});

  Future<void> checkOut(String visitId, String notes);
}
