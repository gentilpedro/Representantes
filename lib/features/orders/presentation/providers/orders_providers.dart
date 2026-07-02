import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_orders_repository.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/repositories/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => MockOrdersRepository(),
);

final ordersListProvider = FutureProvider.autoDispose<List<OrderSummary>>((
  ref,
) {
  return ref.watch(ordersRepositoryProvider).fetchOrders();
});

final orderSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final orderFilterProvider = StateProvider.autoDispose<OrderFilter>(
  (ref) => OrderFilter.all,
);

final filteredOrdersProvider =
    Provider.autoDispose<AsyncValue<List<OrderSummary>>>((ref) {
      final ordersAsync = ref.watch(ordersListProvider);
      final query = ref.watch(orderSearchQueryProvider).trim().toLowerCase();
      final filter = ref.watch(orderFilterProvider);

      return ordersAsync.whenData((orders) {
        return orders.where((order) {
          final matchesQuery =
              query.isEmpty ||
              order.clientName.toLowerCase().contains(query) ||
              order.code.toLowerCase().contains(query);

          final matchesFilter = switch (filter) {
            OrderFilter.all => true,
            OrderFilter.pending => order.status == OrderStatus.pending,
            OrderFilter.sent => order.status == OrderStatus.sent,
            OrderFilter.draft => order.status == OrderStatus.draft,
          };

          return matchesQuery && matchesFilter;
        }).toList();
      });
    });
