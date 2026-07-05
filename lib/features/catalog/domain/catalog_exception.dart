class CatalogException implements Exception {
  CatalogException(this.message);
  final String message;

  @override
  String toString() => message;
}
