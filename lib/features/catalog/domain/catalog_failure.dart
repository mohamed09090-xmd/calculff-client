enum CatalogFailureType {
  networkUnavailable,
  sessionExpired,
  invalidData,
  temporary,
}

class CatalogFailure implements Exception {
  const CatalogFailure(this.type);

  final CatalogFailureType type;
}
