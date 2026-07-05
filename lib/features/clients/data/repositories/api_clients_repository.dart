import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/clients_exception.dart';
import '../../domain/entities/client_detail.dart';
import '../../domain/entities/client_list_item.dart';
import '../../domain/repositories/clients_repository.dart';

/// Implementação real de [ClientsRepository], contra `GET /api/clients`,
/// `GET /api/clients/{id}` e `PATCH /api/clients/{id}/favorite` da Web API
/// .NET 10.
class ApiClientsRepository implements ClientsRepository {
  ApiClientsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ClientListItem>> fetchClients() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/api/clients');
      return response.data!
          .map((json) => _clientListItemFromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ClientsException(_errorMessage(e));
    }
  }

  @override
  Future<ClientDetail> fetchClientDetail(String clientId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/clients/$clientId',
      );
      return _clientDetailFromJson(response.data!);
    } on DioException catch (e) {
      throw ClientsException(_errorMessage(e));
    }
  }

  @override
  Future<void> toggleFavorite(String clientId, bool isFavorite) async {
    try {
      await _apiClient.dio.patch<Map<String, dynamic>>(
        '/api/clients/$clientId/favorite',
        data: {'isFavorite': isFavorite},
      );
    } on DioException catch (e) {
      throw ClientsException(_errorMessage(e));
    }
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
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/clients',
        data: {
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
        },
      );
      return _clientDetailFromJson(response.data!);
    } on DioException catch (e) {
      throw ClientsException(_createClientErrorMessage(e));
    }
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
            (item) =>
                _orderHistoryItemFromJson(item as Map<String, dynamic>),
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
