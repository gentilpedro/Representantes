import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/agenda_exception.dart';
import '../../domain/entities/daily_route.dart';
import '../../domain/entities/scheduled_visit.dart';
import '../../domain/repositories/agenda_repository.dart';

/// Implementação real de [AgendaRepository], contra `GET /api/agenda` e
/// `POST /api/visits/{id}/check-in|check-out` da Web API .NET 10.
class ApiAgendaRepository implements AgendaRepository {
  ApiAgendaRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DailyRoute> fetchDailyRoute(DateTime date) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/agenda',
        queryParameters: {'date': _isoDate(date)},
      );
      return _parseDailyRoute(response.data!);
    } on DioException catch (_) {
      throw AgendaException('Não foi possível carregar a agenda. Tente novamente.');
    }
  }

  @override
  Future<void> checkIn(String visitId, {double? latitude, double? longitude}) async {
    try {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/visits/$visitId/check-in',
        data: {'latitude': latitude, 'longitude': longitude},
      );
    } on DioException catch (_) {
      throw AgendaException('Não foi possível registrar o check-in. Tente novamente.');
    }
  }

  @override
  Future<void> checkOut(String visitId, String notes) async {
    try {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/visits/$visitId/check-out',
        data: {'notes': notes},
      );
    } on DioException catch (_) {
      throw AgendaException('Não foi possível registrar o check-out. Tente novamente.');
    }
  }

  /// `yyyy-MM-dd` — formato exigido pelo binding de `DateOnly` da API.
  String _isoDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${pad(date.month)}-${pad(date.day)}';
  }

  DailyRoute _parseDailyRoute(Map<String, dynamic> json) {
    return DailyRoute(
      // Sem motor de rotas/mapas real por trás — a API não calcula
      // distância/duração do roteiro, só a lista de visitas do dia.
      totalKm: 0,
      estimatedDuration: '',
      visitsPlanned: json['visitsPlanned'] as int,
      routeTip: null,
      visits: (json['visits'] as List<dynamic>)
          .map((v) => _parseVisit(v as Map<String, dynamic>))
          .toList(),
    );
  }

  ScheduledVisit _parseVisit(Map<String, dynamic> json) {
    final scheduledAtLocal = DateTime.parse(
      json['scheduledAtUtc'] as String,
    ).toLocal();

    return ScheduledVisit(
      id: json['id'] as String,
      clientName: json['clientName'] as String,
      scheduledTimeLabel: AppFormatters.timeOfDay(scheduledAtLocal),
      address: json['clientAddress'] as String,
      status: VisitStatus.values.byName(json['status'] as String),
      notes: json['notes'] as String? ?? '',
      isGeoValidated: json['isGeoValidated'] as bool? ?? false,
    );
  }
}
