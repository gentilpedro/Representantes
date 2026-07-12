import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/sync/pending_actions_queue.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/agenda_exception.dart';
import '../../domain/entities/daily_route.dart';
import '../../domain/entities/scheduled_visit.dart';
import '../../domain/repositories/agenda_repository.dart';

const _uuid = Uuid();

/// Implementação real de [AgendaRepository], contra `GET /api/agenda` e
/// `POST /api/visits/{id}/check-in|check-out` da Web API .NET 10.
///
/// A agenda do dia é cacheada no [AppDatabase] (mesma ideia do catálogo e
/// dos clientes) pra que o representante consiga consultar o roteiro do
/// dia mesmo sem conexão. Check-in, check-out e criação de visita sem
/// conexão atualizam esse cache na hora (visita otimista) e enfileiram a
/// ação real via [PendingActionsQueue] (ver `PendingActionsSyncer`), mesmo
/// padrão dos pedidos e clientes offline.
class ApiAgendaRepository implements AgendaRepository {
  ApiAgendaRepository(
    this._apiClient,
    this._db,
    this._connectivity,
    this._queue,
  );

  final ApiClient _apiClient;
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final PendingActionsQueue _queue;

  @override
  Future<DailyRoute> fetchDailyRoute(DateTime date) async {
    final isoDate = _isoDate(date);
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/agenda',
        queryParameters: {'date': isoDate},
      );
      await _db.upsertAgendaJson(isoDate, jsonEncode(response.data));
      return _parseDailyRoute(response.data!);
    } on DioException catch (_) {
      final cachedJson = await _db.fetchAgendaJson(isoDate);
      if (cachedJson != null) {
        return _parseDailyRoute(jsonDecode(cachedJson) as Map<String, dynamic>);
      }
      throw AgendaException(
        'Não foi possível carregar a agenda. Tente novamente.',
      );
    }
  }

  @override
  Future<void> checkIn(
    String visitId,
    DateTime date, {
    double? latitude,
    double? longitude,
  }) async {
    final isGeoValidated = latitude != null && longitude != null;
    if (!await _connectivity.isOnline()) {
      await _enqueueCheckIn(visitId, date, latitude, longitude, isGeoValidated);
      return;
    }
    try {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/visits/$visitId/check-in',
        data: {'latitude': latitude, 'longitude': longitude},
      );
      await _patchCachedVisit(
        date,
        visitId: visitId,
        status: 'inProgress',
        isGeoValidated: isGeoValidated,
      );
    } on DioException catch (e) {
      if (e.response == null) {
        await _enqueueCheckIn(
          visitId,
          date,
          latitude,
          longitude,
          isGeoValidated,
        );
        return;
      }
      throw AgendaException(
        'Não foi possível registrar o check-in. Tente novamente.',
      );
    }
  }

  Future<void> _enqueueCheckIn(
    String visitId,
    DateTime date,
    double? latitude,
    double? longitude,
    bool isGeoValidated,
  ) async {
    await _patchCachedVisit(
      date,
      visitId: visitId,
      status: 'inProgress',
      isGeoValidated: isGeoValidated,
    );
    await _queue.enqueue(PendingActionType.checkInVisit, {
      'visitId': visitId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  Future<void> checkOut(String visitId, DateTime date, String notes) async {
    if (!await _connectivity.isOnline()) {
      await _enqueueCheckOut(visitId, date, notes);
      return;
    }
    try {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/visits/$visitId/check-out',
        data: {'notes': notes},
      );
      await _patchCachedVisit(
        date,
        visitId: visitId,
        status: 'completed',
        notes: notes,
      );
    } on DioException catch (e) {
      if (e.response == null) {
        await _enqueueCheckOut(visitId, date, notes);
        return;
      }
      throw AgendaException(
        'Não foi possível registrar o check-out. Tente novamente.',
      );
    }
  }

  Future<void> _enqueueCheckOut(
    String visitId,
    DateTime date,
    String notes,
  ) async {
    await _patchCachedVisit(
      date,
      visitId: visitId,
      status: 'completed',
      notes: notes,
    );
    await _queue.enqueue(PendingActionType.checkOutVisit, {
      'visitId': visitId,
      'notes': notes,
    });
  }

  /// Atualiza campos de uma visita já presente no cache de um dia (ver
  /// [AppDatabase.fetchAgendaJson]) sem mexer no resto — usado quando
  /// check-in/check-out acontece offline. Não faz nada se aquele dia nunca
  /// foi carregado com conexão (nada em cache pra atualizar).
  Future<void> _patchCachedVisit(
    DateTime date, {
    required String visitId,
    String? status,
    bool? isGeoValidated,
    String? notes,
  }) async {
    final isoDate = _isoDate(date);
    final cachedJson = await _db.fetchAgendaJson(isoDate);
    if (cachedJson == null) return;

    final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
    final visits = (decoded['visits'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final index = visits.indexWhere((v) => v['id'] == visitId);
    if (index == -1) return;

    final visit = Map<String, dynamic>.from(visits[index]);
    if (status != null) visit['status'] = status;
    if (isGeoValidated != null) visit['isGeoValidated'] = isGeoValidated;
    if (notes != null) visit['notes'] = notes;
    visits[index] = visit;
    decoded['visits'] = visits;

    await _db.upsertAgendaJson(isoDate, jsonEncode(decoded));
  }

  @override
  Future<void> createVisit({
    required String clientId,
    required DateTime scheduledAtUtc,
    String? notes,
  }) async {
    final payload = {
      'clientId': clientId,
      'scheduledAtUtc': scheduledAtUtc.toUtc().toIso8601String(),
      'notes': notes,
    };

    if (!await _connectivity.isOnline()) {
      await _createVisitPendingLocally(
        clientId,
        scheduledAtUtc,
        notes,
        payload,
      );
      return;
    }
    try {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/visits',
        data: payload,
      );
    } on DioException catch (e) {
      if (e.response == null) {
        await _createVisitPendingLocally(
          clientId,
          scheduledAtUtc,
          notes,
          payload,
        );
        return;
      }
      throw AgendaException(_createVisitErrorMessage(e));
    }
  }

  /// Adiciona uma visita "provisória" (id `offline-<uuid>`, mesma
  /// convenção dos pedidos/clientes offline) no cache do dia agendado —
  /// se aquele dia nunca foi carregado com conexão, não há nada pra
  /// atualizar (a visita só vai aparecer depois que o dia for consultado
  /// de novo com conexão). Nome/endereço do cliente vêm do cache de
  /// clientes (ver `ApiClientsRepository`).
  Future<void> _createVisitPendingLocally(
    String clientId,
    DateTime scheduledAtUtc,
    String? notes,
    Map<String, dynamic> payload,
  ) async {
    await _queue.enqueue(PendingActionType.createVisit, payload);

    final isoDate = _isoDate(scheduledAtUtc.toLocal());
    final cachedJson = await _db.fetchAgendaJson(isoDate);
    if (cachedJson == null) return;

    final clients = await _db.fetchAllClients();
    ClientsTableData? client;
    for (final c in clients) {
      if (c.id == clientId) {
        client = c;
        break;
      }
    }

    final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
    final visits = (decoded['visits'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    visits.add({
      'id': 'offline-${_uuid.v4()}',
      'clientName': client?.name ?? 'Cliente $clientId',
      'clientAddress': client == null
          ? 'Endereço a confirmar'
          : '${client.city}/${client.state}',
      'scheduledAtUtc': scheduledAtUtc.toUtc().toIso8601String(),
      'status': 'pending',
      'notes': notes ?? '',
      'isGeoValidated': false,
    });
    decoded['visits'] = visits;
    decoded['visitsPlanned'] = (decoded['visitsPlanned'] as int) + 1;

    await _db.upsertAgendaJson(isoDate, jsonEncode(decoded));
  }

  String _createVisitErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is String && data.isNotEmpty) return data;
    if (e.response?.statusCode == 404) return 'Cliente não encontrado.';
    return 'Não foi possível agendar a visita. Tente novamente.';
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
