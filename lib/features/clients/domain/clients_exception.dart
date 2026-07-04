class ClientsException implements Exception {
  ClientsException(this.message);
  final String message;

  @override
  String toString() => message;
}
