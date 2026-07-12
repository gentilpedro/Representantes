import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

const _uuid = Uuid();

/// Identifica o endpoint/verbo de cada ação de escrita enfileirada offline
/// — ver `PendingActionsSyncer` pra saber como cada uma é reenviada.
enum PendingActionType {
  toggleClientFavorite,
  createClient,
  checkInVisit,
  checkOutVisit,
  createVisit,
  createLead,
  updateLead,
  createDraftOrder,
}

/// Enfileira ações de escrita feitas sem conexão (favoritar/criar cliente,
/// check-in/check-out/criar visita, criar/atualizar lead), pra reenviar
/// depois via `PendingActionsSyncer` assim que a conexão voltar.
class PendingActionsQueue {
  PendingActionsQueue(this._db);

  final AppDatabase _db;

  Future<void> enqueue(PendingActionType type, Map<String, dynamic> payload) {
    return _db.savePendingAction(
      id: _uuid.v4(),
      actionType: type.name,
      payload: jsonEncode(payload),
      createdAt: DateTime.now(),
    );
  }
}
