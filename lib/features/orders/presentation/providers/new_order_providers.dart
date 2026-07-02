import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../../clients/domain/entities/client_summary.dart';
import '../../domain/entities/cart_item.dart';

class NewOrderState {
  const NewOrderState({
    required this.client,
    required this.items,
    this.notes = '',
  });

  final ClientSummary? client;
  final List<CartItem> items;
  final String notes;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.unitPrice * item.quantity);

  double get discounts => items.fold(
    0,
    (sum, item) =>
        sum + item.unitPrice * item.quantity * item.discountPercent / 100,
  );

  double get netBeforeTax => subtotal - discounts;

  double get estimatedTaxes => netBeforeTax * 0.08;

  double get total => netBeforeTax + estimatedTaxes;

  NewOrderState copyWith({
    ClientSummary? client,
    List<CartItem>? items,
    String? notes,
  }) {
    return NewOrderState(
      client: client ?? this.client,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }
}

/// Mantém o "pedido em construção" — compartilhado entre a tela de Novo
/// Pedido e o Catálogo/Detalhe do Produto, de onde itens podem ser
/// adicionados diretamente ao carrinho.
class NewOrderController extends Notifier<NewOrderState> {
  @override
  NewOrderState build() {
    return NewOrderState(
      client: const ClientSummary(
        id: '99423',
        name: 'Supermercado Silva & Filhos Ltda',
        cnpj: '12.345.678/0001-90',
        code: '99423',
        creditLimit: 15000,
      ),
      items: const [
        CartItem(
          productId: 'tio-joao-variedades',
          name: 'Arroz Tio João Variedades 1kg',
          sku: 'ARZ-001',
          imageUrl:
              'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200',
          unitPrice: 18.50,
          quantity: 12,
          discountPercent: 5,
        ),
        CartItem(
          productId: 'feijao-meu-biju-preto',
          name: 'Feijão Meu Biju Preto 1kg',
          sku: 'FEJ-042',
          imageUrl:
              'https://images.unsplash.com/photo-1610725664285-7c57e6eea3f3?w=200',
          unitPrice: 9.90,
          quantity: 24,
        ),
      ],
    );
  }

  void selectClient(ClientSummary client) {
    state = state.copyWith(client: client);
  }

  void addProduct(Product product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.productId == product.id,
    );
    if (existingIndex != -1) {
      updateQuantity(product.id, state.items[existingIndex].quantity + 1);
      return;
    }
    state = state.copyWith(
      items: [
        ...state.items,
        CartItem(
          productId: product.id,
          name: product.name,
          sku: product.sku,
          imageUrl: product.imageUrl,
          unitPrice: product.price,
          quantity: 1,
        ),
      ],
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.productId == productId)
            item.copyWith(quantity: quantity)
          else
            item,
      ],
    );
  }

  void updateDiscount(String productId, double discountPercent) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.productId == productId)
            item.copyWith(discountPercent: discountPercent)
          else
            item,
      ],
    );
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.productId != productId).toList(),
    );
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void clear() {
    state = NewOrderState(client: state.client, items: const []);
  }
}

final newOrderControllerProvider =
    NotifierProvider<NewOrderController, NewOrderState>(NewOrderController.new);
