import 'package:josapar_representantes/features/clients/domain/clients_exception.dart';
import 'package:josapar_representantes/features/clients/domain/entities/client_detail.dart';
import 'package:josapar_representantes/features/clients/domain/entities/client_list_item.dart';
import 'package:josapar_representantes/features/clients/domain/repositories/clients_repository.dart';

class FakeClientsRepository implements ClientsRepository {
  FakeClientsRepository() : _clients = List.of(_seed);

  static final _seed = <ClientListItem>[
    const ClientListItem(
      id: 'c1',
      code: 'CLI-88291',
      name: 'Supermercado Silva & Filhos Ltda',
      cnpj: '12.345.678/0001-90',
      city: 'Porto Alegre',
      state: 'RS',
      tier: ClientTier.gold,
      lastOrderDateLabel: '02/07/2026',
      creditLimit: 50000,
      isFavorite: true,
    ),
    const ClientListItem(
      id: 'c2',
      code: 'CLI-77102',
      name: 'Atacado Boa Vista',
      cnpj: '22.333.444/0001-11',
      city: 'Caxias do Sul',
      state: 'RS',
      tier: ClientTier.regular,
      lastOrderDateLabel: '28/06/2026',
      creditLimit: 18000,
    ),
    const ClientListItem(
      id: 'c3',
      code: 'CLI-65310',
      name: 'Padaria Central',
      cnpj: '33.444.555/0001-22',
      city: 'Novo Hamburgo',
      state: 'RS',
      tier: ClientTier.regular,
      lastOrderDateLabel: '20/06/2026',
      creditLimit: 9000,
    ),
    const ClientListItem(
      id: 'c4',
      code: 'CLI-51290',
      name: 'Mercado Vila Nova',
      cnpj: '44.555.666/0001-33',
      city: 'Canoas',
      state: 'RS',
      tier: ClientTier.underReview,
      lastOrderDateLabel: '15/06/2026',
      creditLimit: 6000,
    ),
    const ClientListItem(
      id: 'c5',
      code: 'CLI-40188',
      name: 'Distribuidora Rio Grande',
      cnpj: '55.666.777/0001-44',
      city: 'Gravataí',
      state: 'RS',
      tier: ClientTier.regular,
      lastOrderDateLabel: '10/06/2026',
      creditLimit: 22000,
    ),
    const ClientListItem(
      id: 'c6',
      code: 'CLI-39871',
      name: 'Restaurante Bom Sabor',
      cnpj: '66.777.888/0001-55',
      city: 'Porto Alegre',
      state: 'RS',
      tier: ClientTier.regular,
      lastOrderDateLabel: '05/06/2026',
      creditLimit: 4000,
    ),
    const ClientListItem(
      id: 'c7',
      code: 'CLI-28744',
      name: 'Mercearia do Canto - Unidade',
      cnpj: '77.888.999/0001-66',
      city: 'Viamão',
      state: 'RS',
      tier: ClientTier.regular,
      lastOrderDateLabel: '01/06/2026',
      creditLimit: 3500,
    ),
    const ClientListItem(
      id: 'c8',
      code: 'CLI-17650',
      name: 'Distribuidora Boa Vista',
      cnpj: '88.999.000/0001-77',
      city: 'Novo Hamburgo',
      state: 'RS',
      tier: ClientTier.blocked,
      lastOrderDateLabel: '20/05/2026',
      creditLimit: 10000,
    ),
    const ClientListItem(
      id: 'c9',
      code: 'CLI-10023',
      name: 'Empório Sul',
      cnpj: '99.000.111/0001-88',
      city: 'Esteio',
      state: 'RS',
      tier: ClientTier.regular,
      lastOrderDateLabel: '15/05/2026',
      creditLimit: 5000,
    ),
    const ClientListItem(
      id: 'c10',
      code: 'CLI-90456',
      name: 'Armazém Central',
      cnpj: '10.111.222/0001-99',
      city: 'Sapucaia do Sul',
      state: 'RS',
      tier: ClientTier.regular,
      lastOrderDateLabel: '10/05/2026',
      creditLimit: 4500,
    ),
  ];

  final List<ClientListItem> _clients;

  @override
  Future<List<ClientListItem>> fetchClients() async => List.of(_clients);

  @override
  Future<ClientDetail> fetchClientDetail(String clientId) async {
    final matches = _clients.where((c) => c.id == clientId);
    if (matches.isEmpty) throw ClientsException('Cliente não encontrado.');
    final item = matches.first;

    return ClientDetail(
      id: item.id,
      name: item.name,
      code: item.code,
      cnpj: item.cnpj,
      tier: item.tier,
      phone: '(51) 3222-1000',
      mobile: '(51) 99900-1000',
      email: 'contato@${item.id}.example.com',
      creditLimit: item.creditLimit,
      creditUsedPercent: 0.35,
      deliveryAddress: DeliveryAddress(
        street: 'Av. das Indústrias, 500',
        district: 'Distrito Industrial',
        city: item.city,
        state: item.state,
      ),
      orderHistory: const [],
      pendingInvoice: item.id == 'c1'
          ? const PendingInvoice(dueDateLabel: '10/07/2026', amount: 1200)
          : null,
      isFavorite: item.isFavorite,
    );
  }

  @override
  Future<void> toggleFavorite(String clientId, bool isFavorite) async {
    final index = _clients.indexWhere((c) => c.id == clientId);
    if (index == -1) throw ClientsException('Cliente não encontrado.');
    _clients[index] = _clients[index].copyWith(isFavorite: isFavorite);
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
    final id = 'c${_clients.length + 1}';
    _clients.add(
      ClientListItem(
        id: id,
        code: 'CLI-${10000 + _clients.length}',
        name: name,
        cnpj: cnpj,
        city: deliveryAddress.city,
        state: deliveryAddress.state,
        tier: ClientTier.regular,
        lastOrderDateLabel: 'Sem pedidos',
        creditLimit: creditLimit,
      ),
    );

    return ClientDetail(
      id: id,
      name: name,
      code: 'CLI-${10000 + _clients.length - 1}',
      cnpj: cnpj,
      tier: ClientTier.regular,
      phone: phone,
      mobile: mobile,
      email: email,
      creditLimit: creditLimit,
      creditUsedPercent: 0,
      deliveryAddress: deliveryAddress,
      orderHistory: const [],
      notes: notes,
    );
  }
}
