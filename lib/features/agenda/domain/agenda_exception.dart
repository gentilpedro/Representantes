class AgendaException implements Exception {
  AgendaException(this.message);
  final String message;

  @override
  String toString() => message;
}
