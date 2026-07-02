import 'client_summary.dart';

enum ClientTier { regular, gold, underReview, blocked }

class ClientListItem {
  const ClientListItem({
    required this.id,
    required this.code,
    required this.name,
    required this.cnpj,
    required this.city,
    required this.state,
    required this.tier,
    required this.lastOrderDateLabel,
    required this.creditLimit,
    this.isFavorite = false,
    this.isOffline = false,
  });

  final String id;
  final String code;
  final String name;
  final String cnpj;
  final String city;
  final String state;
  final ClientTier tier;
  final String lastOrderDateLabel;
  final double creditLimit;
  final bool isFavorite;
  final bool isOffline;

  bool get isBlocked => tier == ClientTier.blocked;

  ClientSummary toSummary() {
    return ClientSummary(
      id: id,
      name: name,
      cnpj: cnpj,
      code: code,
      creditLimit: creditLimit,
    );
  }

  ClientListItem copyWith({bool? isFavorite}) {
    return ClientListItem(
      id: id,
      code: code,
      name: name,
      cnpj: cnpj,
      city: city,
      state: state,
      tier: tier,
      lastOrderDateLabel: lastOrderDateLabel,
      creditLimit: creditLimit,
      isFavorite: isFavorite ?? this.isFavorite,
      isOffline: isOffline,
    );
  }
}
