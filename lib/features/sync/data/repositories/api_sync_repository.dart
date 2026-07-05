import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/sync_summary.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/sync_exception.dart';

/// Implementação real de [SyncRepository], contra `GET /api/sync/summary` da
/// Web API .NET 10 — só dados reais (última sincronização, contagem de
/// sucesso). Sem fila/histórico/conflito fictício: quem monta a fila de
/// verdade é o `SyncController`, a partir dos pedidos locais pendentes.
class ApiSyncRepository implements SyncRepository {
  ApiSyncRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SyncSummary> fetchSummary() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/sync/summary',
      );
      return _parseSummary(response.data!);
    } on DioException catch (_) {
      throw SyncException(
        'Não foi possível carregar a sincronização. Tente novamente.',
      );
    }
  }

  @override
  Future<SyncSummary> syncNow() => fetchSummary();

  SyncSummary _parseSummary(Map<String, dynamic> json) {
    final lastSyncedAtUtc = json['lastSyncedAtUtc'] as String?;

    return SyncSummary(
      isConnected: true,
      lastUpdateLabel: lastSyncedAtUtc == null
          ? 'Nunca sincronizado'
          : _formatLastUpdate(DateTime.parse(lastSyncedAtUtc).toLocal()),
      pendingCount: 0,
      successCount: json['successCount'] as int,
      queue: const [],
      history: const [],
      conflict: null,
    );
  }

  String _formatLastUpdate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final time = AppFormatters.timeOfDay(date);
    return isToday ? 'Hoje, $time' : '${AppFormatters.shortDate(date)}, $time';
  }
}
