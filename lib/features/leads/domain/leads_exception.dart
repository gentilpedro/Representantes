class LeadsException implements Exception {
  LeadsException(this.message);
  final String message;

  @override
  String toString() => message;
}
