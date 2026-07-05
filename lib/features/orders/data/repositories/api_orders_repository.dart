import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/orders_exception.dart';
import '../../domain/repositories/orders_repository.dart';

const _uuid = Uuid();

/// Implementação real de [OrdersRepository], contra `/api/orders` da Web API
/// .NET 10. Pedidos finalizados (`isDraft: false`) sem conexão são gravados
/// numa fila local (Drift) e enviados de uma vez em [syncPendingOrders] via
/// `POST /api/orders/batch-sync` — rascunhos nunca entram nessa fila.
class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this._apiClient, this._db, this._connectivity);

  final ApiClient _apiClient;
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  @override
  Future<List<OrderSummary>> fetchOrders() async {
    var remote = <OrderSummary>[];
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/api/orders');
      remote = response.data!
          .cast<Map<String, dynamic>>()
          .map(_toOrderSummary)
          .toList();
    } on DioException catch (_) {
      // Sem conexão com o servidor: mostra só o que já está na fila local.
    }

    final pending = await _pendingOrderSummaries();
    return [...pending, ...remote];
  }

  @override
  Future<OrderSummary> createOrder({
    required String clientId,
    required String clientName,
    required List<CartItem> items,
    String? notes,
    required bool isDraft,
  }) async {
    if (!isDraft && !await _connectivity.isOnline()) {
      return _createPendingLocally(
        clientId: clientId,
        clientName: clientName,
        items: items,
        notes: notes,
      );
    }

    return _createRemote(
      clientId: clientId,
      items: items,
      notes: notes,
      isDraft: isDraft,
    );
  }

  @override
  Future<int> syncPendingOrders() async {
    final pendingRows = await _db.fetchPendingOrders();
    if (pendingRows.isEmpty) return 0;

    final payload = <Map<String, dynamic>>[];
    for (final order in pendingRows) {
      final items = await _db.fetchPendingOrderItems(order.id);
      payload.add({
        'clientGeneratedId': order.id,
        'clientId': order.clientId,
        'notes': order.notes,
        'items': items
            .map(
              (item) => {
                'productId': item.productId,
                'quantity': item.quantity,
                'discountPercent': item.discountPercent,
              },
            )
            .toList(),
      });
    }

    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/orders/batch-sync',
        data: payload,
      );
      final createdCount =
          (response.data!['created'] as List<dynamic>).length;

      for (final order in pendingRows) {
        await _db.deletePendingOrder(order.id);
      }

      return createdCount;
    } on DioException catch (_) {
      throw OrdersException('Não foi possível sincronizar os pedidos.');
    }
  }

  Future<OrderSummary> _createRemote({
    required String clientId,
    required List<CartItem> items,
    String? notes,
    required bool isDraft,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/orders',
        data: {
          'clientId': clientId,
          'notes': notes,
          'isDraft': isDraft,
          'items': items
              .map(
                (item) => {
                  'productId': item.productId,
                  'quantity': item.quantity,
                  'discountPercent': item.discountPercent,
                },
              )
              .toList(),
        },
      );
      return _toOrderSummary(response.data!);
    } on DioException catch (e) {
      throw OrdersException(_createOrderErrorMessage(e));
    }
  }

  Future<OrderSummary> _createPendingLocally({
    required String clientId,
    required String clientName,
    required List<CartItem> items,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final total = _estimateTotal(items);

    await _db.savePendingOrder(
      id: id,
      clientId: clientId,
      clientName: clientName,
      notes: notes,
      total: total,
      createdAt: now,
      items: items
          .map(
            (item) => PendingOrderItemsTableCompanion.insert(
              id: _uuid.v4(),
              orderId: id,
              productId: item.productId,
              productName: item.name,
              productSku: item.sku,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              discountPercent: item.discountPercent,
            ),
          )
          .toList(),
    );

    return OrderSummary(
      id: id,
      code: 'OFFLINE-${id.substring(0, 4).toUpperCase()}',
      clientName: clientName,
      dateLabel: AppFormatters.shortDate(now),
      itemsCount: items.length,
      total: total,
      status: OrderStatus.pending,
      isToday: true,
    );
  }

  Future<List<OrderSummary>> _pendingOrderSummaries() async {
    final rows = await _db.fetchPendingOrders();
    final summaries = <OrderSummary>[];
    for (final row in rows) {
      final items = await _db.fetchPendingOrderItems(row.id);
      summaries.add(
        OrderSummary(
          id: row.id,
          code: 'OFFLINE-${row.id.substring(0, 4).toUpperCase()}',
          clientName: row.clientName,
          dateLabel: AppFormatters.shortDate(row.createdAt),
          itemsCount: items.length,
          total: row.total,
          status: OrderStatus.pending,
          isToday: true,
        ),
      );
    }
    return summaries;
  }

  double _estimateTotal(List<CartItem> items) {
    final subtotal = items.fold<double>(0, (sum, i) => sum + i.subtotal);
    return subtotal * 1.08;
  }

  String _createOrderErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is String && data.isNotEmpty) return data;
    switch (e.response?.statusCode) {
      case 400:
        return 'Não foi possível criar o pedido. Verifique os dados informados.';
      case 404:
        return 'Cliente ou produto não encontrado.';
      default:
        return 'Não foi possível criar o pedido. Tente novamente.';
    }
  }

  OrderSummary _toOrderSummary(Map<String, dynamic> json) {
    final createdAtLocal = DateTime.parse(
      json['createdAtUtc'] as String,
    ).toLocal();
    final now = DateTime.now();
    final isToday =
        createdAtLocal.year == now.year &&
        createdAtLocal.month == now.month &&
        createdAtLocal.day == now.day;
    final items = json['items'] as List<dynamic>? ?? const [];

    return OrderSummary(
      id: json['id'] as String,
      code: json['code'] as String,
      clientName: json['clientName'] as String,
      dateLabel: AppFormatters.shortDate(createdAtLocal),
      itemsCount: items.length,
      total: (json['total'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      isToday: isToday,
    );
  }

  OrderStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'sent':
        return OrderStatus.sent;
      case 'error':
        return OrderStatus.error;
      case 'draft':
        return OrderStatus.draft;
      default:
        return OrderStatus.pending;
    }
  }
}
