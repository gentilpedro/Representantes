import 'dart:convert';

import 'package:dio/dio.dart';

import '../database/app_database.dart';
import '../network/api_client.dart';
import 'pending_actions_queue.dart';

/// Base pra permitir substituir por um fake nos testes — a implementação
/// real usa o [AppDatabase] de verdade (Drift/`path_provider`, sem canal de
/// plataforma mockado no `flutter_test`), e `SyncController` sempre a
/// referencia mesmo em telas que não mexem com nada offline.
abstract class PendingActionsSyncerBase {
  Future<void> syncAll();
}

/// Reenvia a fila de ações de escrita feitas offline (ver
/// [PendingActionsQueue]) assim que a conexão volta. Erros de rede deixam a
/// ação na fila pra tentar de novo na próxima; erros de verdade do servidor
/// (400/404/...) descartam a ação — repetir não vai resolver (ex: cliente
/// ou produto que deixou de existir).
class PendingActionsSyncer implements PendingActionsSyncerBase {
  PendingActionsSyncer(this._db, this._apiClient);

  final AppDatabase _db;
  final ApiClient _apiClient;

  @override
  Future<void> syncAll() async {
    final pending = await _db.fetchPendingActions();
    for (final action in pending) {
      final payload = jsonDecode(action.payload) as Map<String, dynamic>;
      final type = PendingActionType.values.byName(action.actionType);
      try {
        await _replay(type, payload);
        await _db.deletePendingAction(action.id);
        if (type == PendingActionType.createDraftOrder) {
          // O rascunho tem uma linha própria em PendingOrdersTable (pra
          // aparecer na lista de Pedidos antes de sincronizar) que
          // `syncPendingOrders` não toca (só cuida de pedidos não-rascunho)
          // — cabe aqui limpar depois que o POST de verdade deu certo.
          await _db.deletePendingOrder(payload['localOrderId'] as String);
        }
      } on DioException catch (e) {
        if (e.response != null) {
          await _db.deletePendingAction(action.id);
        }
        // Sem resposta (offline de novo, timeout): mantém na fila.
      }
    }
  }

  Future<void> _replay(PendingActionType type, Map<String, dynamic> payload) {
    return switch (type) {
      PendingActionType.toggleClientFavorite => _apiClient.dio.patch(
        '/api/clients/${payload['clientId']}/favorite',
        data: {'isFavorite': payload['isFavorite']},
      ),
      PendingActionType.createClient => _apiClient.dio.post(
        '/api/clients',
        data: payload,
      ),
      PendingActionType.checkInVisit => _apiClient.dio.post(
        '/api/visits/${payload['visitId']}/check-in',
        data: {
          'latitude': payload['latitude'],
          'longitude': payload['longitude'],
        },
      ),
      PendingActionType.checkOutVisit => _apiClient.dio.post(
        '/api/visits/${payload['visitId']}/check-out',
        data: {'notes': payload['notes']},
      ),
      PendingActionType.createVisit => _apiClient.dio.post(
        '/api/visits',
        data: payload,
      ),
      PendingActionType.createLead => _apiClient.dio.post(
        '/api/leads',
        data: payload,
      ),
      PendingActionType.updateLead => _apiClient.dio.patch(
        '/api/leads/${payload['id']}',
        // `id` só serve pra montar a URL acima — o corpo não deve levá-lo,
        // mesma forma da chamada online (ver `ApiLeadsRepository.updateLead`).
        data: {...payload}..remove('id'),
      ),
      PendingActionType.createDraftOrder => _apiClient.dio.post(
        '/api/orders',
        // `localOrderId` só serve pra `syncAll` limpar o
        // `PendingOrdersTable` depois — não faz parte do corpo esperado
        // pela API (mesmo request de `ApiOrdersRepository._createRemote`).
        data: {...payload}..remove('localOrderId'),
      ),
    };
  }
}
