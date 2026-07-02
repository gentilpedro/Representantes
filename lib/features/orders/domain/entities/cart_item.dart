class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.sku,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.discountPercent = 0,
  });

  final String productId;
  final String name;
  final String sku;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final double discountPercent;

  double get subtotal => unitPrice * quantity * (1 - discountPercent / 100);

  CartItem copyWith({int? quantity, double? discountPercent}) {
    return CartItem(
      productId: productId,
      name: name,
      sku: sku,
      imageUrl: imageUrl,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}
