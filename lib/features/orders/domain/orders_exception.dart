class OrdersException implements Exception {
  OrdersException(this.message);
  final String message;

  @override
  String toString() => message;
}
