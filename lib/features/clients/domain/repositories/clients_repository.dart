import '../entities/client_detail.dart';
import '../entities/client_list_item.dart';

/// Contrato de clientes. A implementação real deve consumir a Web API .NET 10
/// (ex: `GET /api/clients`, `GET /api/clients/{id}`).
abstract class ClientsRepository {
  Future<List<ClientListItem>> fetchClients();

  Future<ClientDetail> fetchClientDetail(String clientId);

  Future<void> toggleFavorite(String clientId, bool isFavorite);

  /// Cadastra um cliente novo pelo app. O servidor gera o `code` e inicia o
  /// cliente como `Regular`, sem favorito e sem uso de crédito.
  Future<ClientDetail> createClient({
    required String name,
    required String cnpj,
    required String phone,
    required String mobile,
    required String email,
    required double creditLimit,
    required DeliveryAddress deliveryAddress,
    String? notes,
  });
}
