import '../domain/catalog_game.dart';
import '../domain/catalog_offer.dart';

class CatalogOfferRouteData {
  const CatalogOfferRouteData({required this.game, required this.offer});

  final CatalogGame game;
  final CatalogOffer offer;
}
