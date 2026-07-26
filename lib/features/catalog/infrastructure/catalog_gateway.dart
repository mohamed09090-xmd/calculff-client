abstract interface class CatalogGateway {
  Future<List<Map<String, Object?>>> fetchActiveGames();

  Future<List<Map<String, Object?>>> fetchPublishedOffers(String gameId);
}
