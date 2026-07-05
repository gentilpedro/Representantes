import 'client_list_item.dart';

class PendingInvoice {
  const PendingInvoice({required this.dueDateLabel, required this.amount});

  final String dueDateLabel;
  final double amount;
}

class DeliveryAddress {
  const DeliveryAddress({
    required this.street,
    required this.district,
    required this.city,
    required this.state,
  });

  final String street;
  final String district;
  final String city;
  final String state;
}

class ClientOrderHistoryItem {
  const ClientOrderHistoryItem({
    required this.code,
    required this.dateLabel,
    required this.amount,
    required this.statusLabel,
  });

  final String code;
  final String dateLabel;
  final double amount;
  final String statusLabel;
}

class ClientDetail {
  const ClientDetail({
    required this.id,
    required this.name,
    required this.code,
    required this.cnpj,
    required this.tier,
    required this.phone,
    required this.mobile,
    required this.email,
    required this.creditLimit,
    required this.creditUsedPercent,
    required this.deliveryAddress,
    required this.orderHistory,
    this.pendingInvoice,
    this.notes,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String code;
  final String cnpj;
  final ClientTier tier;
  final String phone;
  final String mobile;
  final String email;
  final double creditLimit;
  final double creditUsedPercent;
  final DeliveryAddress deliveryAddress;
  final List<ClientOrderHistoryItem> orderHistory;
  final PendingInvoice? pendingInvoice;
  final String? notes;
  final bool isFavorite;

  double get creditAvailable => creditLimit * (1 - creditUsedPercent);
}
