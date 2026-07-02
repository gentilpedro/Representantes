import '../entities/daily_route.dart';

/// Contrato da agenda. A implementação real deve consumir a Web API .NET 10
/// (ex: `GET /api/agenda?date=...`) e persistir check-in/check-out via
/// `POST /api/visits/{id}/checkin`.
abstract class AgendaRepository {
  Future<DailyRoute> fetchDailyRoute(DateTime date);
}
