import 'catalog_game.dart';
import 'catalog_offer.dart';

abstract interface class CatalogRepository {
  Future<List<CatalogGame>> fetchActiveGames();

  Future<List<CatalogOffer>> fetchPublishedOffers(CatalogGame game);
}
