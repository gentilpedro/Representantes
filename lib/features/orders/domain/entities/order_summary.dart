enum OrderStatus { pending, sent, error, draft }

enum OrderFilter { all, pending, sent, draft }

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.code,
    required this.clientName,
    required this.dateLabel,
    required this.itemsCount,
    required this.total,
    required this.status,
    required this.isToday,
  });

  final String id;
  final String code;
  final String clientName;
  final String dateLabel;
  final int itemsCount;
  final double total;
  final OrderStatus status;
  final bool isToday;

  OrderSummary copyWith({OrderStatus? status}) {
    return OrderSummary(
      id: id,
      code: code,
      clientName: clientName,
      dateLabel: dateLabel,
      itemsCount: itemsCount,
      total: total,
      status: status ?? this.status,
      isToday: isToday,
    );
  }
}
