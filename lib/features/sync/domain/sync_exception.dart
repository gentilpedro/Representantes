class SyncException implements Exception {
  SyncException(this.message);
  final String message;

  @override
  String toString() => message;
}
