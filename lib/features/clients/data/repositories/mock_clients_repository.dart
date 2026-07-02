import 'dart:async';

import 'package:hive/hive.dart';

import '../../domain/entities/client_detail.dart';
import '../../domain/entities/client_list_item.dart';
import '../../domain/repositories/clients_repository.dart';
import '../local/cached_client.dart';

/// Carteira de clientes cacheada localmente (box `clients_cache`),
/// espelhando as telas "Clientes" e "Detalhe do Cliente" do protótipo. Na
/// primeira execução semeia com os dados fixos abaixo (inclui o cliente
/// "Supermercado Silva & Filhos Ltda", também referenciado em Pedidos e
/// Novo Pedido), simulando "o último download semanal" — quando a Web API
/// existir, [refreshCache] passa a baixar de verdade em vez de re-semear os
/// mesmos exemplos. O app lê sempre do cache local, então funciona offline
/// entre atualizações.
class MockClientsRepository implements ClientsRepository {
  MockClientsRepository(this._box) {
    if (_box.isEmpty) {
      for (var i = 0; i < _seedClients.length; i++) {
        final client = _seedClients[i];
        _box.put(client.id, CachedClient.fromClient(client, sortOrder: i));
      }
    }
  }

  final Box<CachedClient> _box;

  static const _seedClients = [
    ClientListItem(
      id: 'silva-88291',
      code: '88291',
      name: 'Supermercado Silva & Filhos Ltda',
      cnpj: '12.345.678/0001-99',
      city: 'Pelotas',
      state: 'RS',
      tier: ClientTier.gold,
      lastOrderDateLabel: '15/10/2023',
      creditLimit: 50000,
      isFavorite: true,
    ),
    ClientListItem(
      id: '001245',
      code: '001245',
      name: 'Supermercados Alvorada Ltda',
      cnpj: '12.345.678/0001-90',
      city: 'Porto Alegre',
      state: 'RS',
      tier: ClientTier.regular,
      lastOrderDateLabel: '12/10/2023',
      creditLimit: 20000,
    ),
    ClientListItem(
      id: '001389',
      code: '001389',
      name: 'Distribuidora de Alimentos Josapar',
      cnpj: '98.765.432/0001-21',
      city: 'Belém',
      state: 'PA',
      tier: ClientTier.blocked,
      lastOrderDateLabel: '05/09/2023',
      creditLimit: 20000,
      isOffline: true,
    ),
    ClientListItem(
      id: '002510',
      code: '002510',
      name: 'Mercearia do Canto - Unidade',
      cnpj: '45.123.890/0001-55',
      city: 'São Paulo',
      state: 'SP',
      tier: ClientTier.regular,
      lastOrderDateLabel: '20/10/2023',
      creditLimit: 20000,
    ),
    ClientListItem(
      id: '000982',
      code: '000982',
      name: 'Atacadão Rio Grande',
      cnpj: '11.222.333/0001-44',
      city: 'Pelotas',
      state: 'RS',
      tier: ClientTier.underReview,
      lastOrderDateLabel: '15/10/2023',
      creditLimit: 20000,
      isFavorite: true,
    ),
  ];

  List<ClientListItem> get _clients {
    final cached = _box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return cached.map((c) => c.toClient()).toList();
  }

  @override
  Future<List<ClientListItem>> fetchClients() async {
    await Future.delayed(const Duration(milliseconds: 450));
    return _clients;
  }

  @override
  Future<ClientDetail> fetchClientDetail(String clientId) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final client = _clients.firstWhere((c) => c.id == clientId);

    if (clientId == 'silva-88291') {
      return const ClientDetail(
        id: 'silva-88291',
        name: 'Supermercado Silva & Filhos Ltda',
        code: 'CLI-88291',
        cnpj: '12.345.678/0001-99',
        tier: ClientTier.gold,
        phone: '(53) 3225-1234',
        mobile: '(53) 99911-2233',
        email: 'compras@silvaefilhos.com.br',
        creditLimit: 50000,
        creditUsedPercent: 0.65,
        pendingInvoice: PendingInvoice(
          dueDateLabel: '25/10/2023',
          amount: 1250.00,
        ),
        deliveryAddress: DeliveryAddress(
          street: 'Av. das Nações, 1500',
          district: 'Distrito Industrial',
          city: 'Pelotas',
          state: 'RS',
        ),
        orderHistory: [
          ClientOrderHistoryItem(
            code: '#10293',
            dateLabel: '15/10/2023',
            amount: 4560.80,
            statusLabel: 'Entregue',
          ),
          ClientOrderHistoryItem(
            code: '#10155',
            dateLabel: '02/10/2023',
            amount: 2300.00,
            statusLabel: 'Entregue',
          ),
        ],
      );
    }

    return ClientDetail(
      id: client.id,
      name: client.name,
      code: 'CLI-${client.code}',
      cnpj: client.cnpj,
      tier: client.tier,
      phone: '(00) 0000-0000',
      mobile: '(00) 90000-0000',
      email: 'contato@${client.name.split(' ').first.toLowerCase()}.com.br',
      creditLimit: 20000,
      creditUsedPercent: 0.3,
      deliveryAddress: DeliveryAddress(
        street: 'Endereço não informado',
        district: '-',
        city: client.city,
        state: client.state,
      ),
      orderHistory: const [],
      notes: null,
    );
  }

  /// Reaponta o cache para os dados mais recentes do servidor. Sem uma Web
  /// API real ainda, só re-semeia os mesmos exemplos — a peça (box +
  /// método) já fica pronta para virar um download semanal de verdade.
  Future<void> refreshCache() async {
    // Não aguarda o flush em disco (mesmo motivo de `MockOrdersRepository`):
    // `Box.clear`/`Box.put` já atualizam o estado em memória na hora.
    unawaited(_box.clear());
    for (var i = 0; i < _seedClients.length; i++) {
      final client = _seedClients[i];
      unawaited(
        _box.put(client.id, CachedClient.fromClient(client, sortOrder: i)),
      );
    }
  }
}
