import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/sync/pending_actions_queue.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/clients_exception.dart';
import '../../domain/entities/client_detail.dart';
import '../../domain/entities/client_list_item.dart';
import '../../domain/repositories/clients_repository.dart';

const _uuid = Uuid();

/// Implementação real de [ClientsRepository], contra `GET /api/clients`,
/// `GET /api/clients/{id}` e `PATCH /api/clients/{id}/favorite` da Web API
/// .NET 10.
///
/// Igual ao catálogo (ver `ApiCatalogRepository`): lista e detalhe de
/// clientes são cacheados no [AppDatabase] a cada busca bem-sucedida, pra
/// que o representante consiga consultar e selecionar cliente pra um
/// pedido mesmo sem conexão. Favoritar e criar cliente sem conexão
/// atualizam o cache local na hora e enfileiram a ação real via
/// [PendingActionsQueue] (ver `PendingActionsSyncer`), mesmo padrão dos
/// pedidos offline.
class ApiClientsRepository implements ClientsRepository {
  ApiClientsRepository(
    this._apiClient,
    this._db,
    this._connectivity,
    this._queue,
  );

  static const _dataset = 'clients';

  final ApiClient _apiClient;
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final PendingActionsQueue _queue;

  @override
  Future<List<ClientListItem>> fetchClients() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/api/clients');
      final jsonList = response.data!.cast<Map<String, dynamic>>();
      final clients = jsonList.map(_clientListItemFromJson).toList();
      // Cacheia a partir do JSON bruto (não da entidade já convertida) pra
      // preservar o `lastOrderAtUtc` de verdade — a entidade só carrega o
      // rótulo já formatado (`lastOrderDateLabel`), não a data original.
      await _db.replaceAllClients(
        jsonList.map(_clientToCompanionFromJson).toList(),
      );
      await _db.upsertSyncMetadata(_dataset, DateTime.now());
      return clients;
    } on DioException catch (e) {
      final cached = await _db.fetchAllClients();
      if (cached.isNotEmpty) {
        return cached.map(_clientFromRow).toList();
      }
      throw ClientsException(_errorMessage(e));
    }
  }

  @override
  Future<ClientDetail> fetchClientDetail(String clientId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/clients/$clientId',
      );
      await _db.upsertClientDetailJson(clientId, jsonEncode(response.data));
      return _clientDetailFromJson(response.data!);
    } on DioException catch (e) {
      final cachedJson = await _db.fetchClientDetailJson(clientId);
      if (cachedJson != null) {
        return _clientDetailFromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>,
        );
      }
      throw ClientsException(_errorMessage(e));
    }
  }

  @override
  Future<void> toggleFavorite(String clientId, bool isFavorite) async {
    if (!await _connectivity.isOnline()) {
      await _enqueueFavoriteToggle(clientId, isFavorite);
      return;
    }
    try {
      await _apiClient.dio.patch<Map<String, dynamic>>(
        '/api/clients/$clientId/favorite',
        data: {'isFavorite': isFavorite},
      );
      await _db.updateCachedClientFavorite(clientId, isFavorite);
    } on DioException catch (e) {
      // Sem resposta = a conexão caiu no meio da requisição (não é um erro
      // de validação de verdade) — trata como offline em vez de perder a
      // ação.
      if (e.response == null) {
        await _enqueueFavoriteToggle(clientId, isFavorite);
        return;
      }
      throw ClientsException(_errorMessage(e));
    }
  }

  Future<void> _enqueueFavoriteToggle(String clientId, bool isFavorite) async {
    await _db.updateCachedClientFavorite(clientId, isFavorite);
    await _queue.enqueue(PendingActionType.toggleClientFavorite, {
      'clientId': clientId,
      'isFavorite': isFavorite,
    });
  }

  ClientsTableCompanion _clientToCompanionFromJson(Map<String, dynamic> json) {
    final lastOrderAtUtc = json['lastOrderAtUtc'] as String?;
    return ClientsTableCompanion.insert(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      cnpj: json['cnpj'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      tier: json['tier'] as String,
      lastOrderAtUtc: Value(
        lastOrderAtUtc == null ? null : DateTime.parse(lastOrderAtUtc),
      ),
      creditLimit: (json['creditLimit'] as num).toDouble(),
      isFavorite: Value(json['isFavorite'] as bool),
    );
  }

  ClientListItem _clientFromRow(ClientsTableData row) {
    return ClientListItem(
      id: row.id,
      code: row.code,
      name: row.name,
      cnpj: row.cnpj,
      city: row.city,
      state: row.state,
      tier: _tierFromJson(row.tier),
      lastOrderDateLabel: row.lastOrderAtUtc == null
          ? 'Sem pedidos'
          : AppFormatters.shortDate(row.lastOrderAtUtc!),
      creditLimit: row.creditLimit,
      isFavorite: row.isFavorite,
      isOffline: true,
    );
  }

  @override
  Future<ClientDetail> createClient({
    required String name,
    required String cnpj,
    required String phone,
    required String mobile,
    required String email,
    required double creditLimit,
    required DeliveryAddress deliveryAddress,
    String? notes,
  }) async {
    final payload = {
      'name': name,
      'cnpj': cnpj,
      'phone': phone,
      'mobile': mobile,
      'email': email,
      'creditLimit': creditLimit,
      'deliveryAddress': {
        'street': deliveryAddress.street,
        'district': deliveryAddress.district,
        'city': deliveryAddress.city,
        'state': deliveryAddress.state,
      },
      'notes': notes,
    };

    if (!await _connectivity.isOnline()) {
      return _createPendingLocally(payload);
    }
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/clients',
        data: payload,
      );
      return _clientDetailFromJson(response.data!);
    } on DioException catch (e) {
      if (e.response == null) {
        return _createPendingLocally(payload);
      }
      throw ClientsException(_createClientErrorMessage(e));
    }
  }

  /// Cria um cliente "provisório" só no cache local (id/código `OFFLINE-`,
  /// mesma convenção dos pedidos offline) pra aparecer na lista/detalhe na
  /// hora, e enfileira a criação de verdade. Quando a lista for
  /// sincronizada de novo (com conexão), o cliente provisório é substituído
  /// pelo real, já que `replaceAllClients` reflete o servidor por inteiro.
  Future<ClientDetail> _createPendingLocally(
    Map<String, dynamic> payload,
  ) async {
    final tempId = 'offline-${_uuid.v4()}';
    final tempCode = 'OFFLINE-${tempId.substring(8, 12).toUpperCase()}';
    final addressJson = payload['deliveryAddress'] as Map<String, dynamic>;

    await _queue.enqueue(PendingActionType.createClient, payload);
    await _db.insertClient(
      ClientsTableCompanion.insert(
        id: tempId,
        code: tempCode,
        name: payload['name'] as String,
        cnpj: payload['cnpj'] as String,
        city: addressJson['city'] as String,
        state: addressJson['state'] as String,
        tier: ClientTier.regular.name,
        lastOrderAtUtc: const Value(null),
        creditLimit: payload['creditLimit'] as double,
      ),
    );

    final detailJson = {
      'id': tempId,
      'name': payload['name'],
      'code': tempCode,
      'cnpj': payload['cnpj'],
      'tier': ClientTier.regular.name,
      'phone': payload['phone'],
      'mobile': payload['mobile'],
      'email': payload['email'],
      'creditLimit': payload['creditLimit'],
      'creditUsedPercent': 0.0,
      'deliveryAddress': addressJson,
      'pendingInvoice': null,
      'notes': payload['notes'],
      'isFavorite': false,
      'orderHistory': <dynamic>[],
    };
    await _db.upsertClientDetailJson(tempId, jsonEncode(detailJson));
    return _clientDetailFromJson(detailJson);
  }

  String _createClientErrorMessage(DioException e) {
    if (e.response?.statusCode == 409) {
      return 'Já existe um cliente cadastrado com esse CNPJ.';
    }
    final data = e.response?.data;
    if (data is String && data.isNotEmpty) return data;
    return 'Não foi possível cadastrar o cliente. Tente novamente.';
  }

  String _errorMessage(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'Cliente não encontrado.';
    }
    return 'Não foi possível carregar os clientes. Tente novamente.';
  }

  ClientListItem _clientListItemFromJson(Map<String, dynamic> json) {
    final lastOrderAtUtc = json['lastOrderAtUtc'] as String?;
    return ClientListItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      cnpj: json['cnpj'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      tier: _tierFromJson(json['tier'] as String),
      lastOrderDateLabel: lastOrderAtUtc == null
          ? 'Sem pedidos'
          : AppFormatters.shortDate(DateTime.parse(lastOrderAtUtc)),
      creditLimit: (json['creditLimit'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool,
    );
  }

  ClientDetail _clientDetailFromJson(Map<String, dynamic> json) {
    final pendingInvoiceJson = json['pendingInvoice'] as Map<String, dynamic>?;
    final addressJson = json['deliveryAddress'] as Map<String, dynamic>;
    final orderHistoryJson = json['orderHistory'] as List<dynamic>;

    return ClientDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      cnpj: json['cnpj'] as String,
      tier: _tierFromJson(json['tier'] as String),
      phone: json['phone'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String,
      creditLimit: (json['creditLimit'] as num).toDouble(),
      creditUsedPercent: (json['creditUsedPercent'] as num).toDouble(),
      deliveryAddress: DeliveryAddress(
        street: addressJson['street'] as String,
        district: addressJson['district'] as String,
        city: addressJson['city'] as String,
        state: addressJson['state'] as String,
      ),
      pendingInvoice: pendingInvoiceJson == null
          ? null
          : PendingInvoice(
              dueDateLabel: AppFormatters.shortDate(
                DateTime.parse(pendingInvoiceJson['dueDateUtc'] as String),
              ),
              amount: (pendingInvoiceJson['amount'] as num).toDouble(),
            ),
      notes: json['notes'] as String?,
      isFavorite: json['isFavorite'] as bool,
      orderHistory: orderHistoryJson
          .map(
            (item) => _orderHistoryItemFromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  ClientOrderHistoryItem _orderHistoryItemFromJson(Map<String, dynamic> json) {
    return ClientOrderHistoryItem(
      code: json['code'] as String,
      dateLabel: AppFormatters.shortDate(
        DateTime.parse(json['createdAtUtc'] as String),
      ),
      amount: (json['total'] as num).toDouble(),
      statusLabel: _orderStatusLabelFromJson(json['status'] as String),
    );
  }

  ClientTier _tierFromJson(String value) {
    switch (value) {
      case 'regular':
        return ClientTier.regular;
      case 'gold':
        return ClientTier.gold;
      case 'underReview':
        return ClientTier.underReview;
      case 'blocked':
        return ClientTier.blocked;
      default:
        throw ClientsException('Categoria de cliente desconhecida: $value');
    }
  }

  String _orderStatusLabelFromJson(String value) {
    switch (value) {
      case 'pending':
        return 'PENDENTE';
      case 'sent':
        return 'ENVIADO';
      case 'error':
        return 'ERRO';
      case 'draft':
        return 'RASCUNHO';
      default:
        throw ClientsException('Status de pedido desconhecido: $value');
    }
  }
}
