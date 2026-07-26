import '../domain/catalog_game.dart';
import '../domain/catalog_offer.dart';
import '../domain/catalog_repository.dart';
import 'catalog_dtos.dart';
import 'catalog_error_mapper.dart';
import 'catalog_gateway.dart';

class SupabaseCatalogRepository implements CatalogRepository {
  const SupabaseCatalogRepository(this._gateway);

  final CatalogGateway _gateway;

  @override
  Future<List<CatalogGame>> fetchActiveGames() async {
    try {
      final rows = await _gateway.fetchActiveGames();
      final games =
          rows
              .map(CatalogGameDto.fromMap)
              .map((dto) => dto.toDomain())
              .where((game) => game.isActive)
              .toList(growable: false)
            ..sort(_compareGames);
      return List<CatalogGame>.unmodifiable(games);
    } catch (error) {
      throw CatalogErrorMapper.map(error);
    }
  }

  @override
  Future<List<CatalogOffer>> fetchPublishedOffers(CatalogGame game) async {
    if (!game.isActive) return const <CatalogOffer>[];
    try {
      final rows = await _gateway.fetchPublishedOffers(game.id);
      final offers =
          rows
              .map(CatalogOfferDto.fromMap)
              .map((dto) => dto.toDomain())
              .where((offer) => offer.isPublished && offer.gameId == game.id)
              .toList(growable: false)
            ..sort(_compareOffers);
      return List<CatalogOffer>.unmodifiable(offers);
    } catch (error) {
      throw CatalogErrorMapper.map(error);
    }
  }
}

int _compareGames(CatalogGame left, CatalogGame right) {
  final order = left.sortOrder.compareTo(right.sortOrder);
  return order == 0 ? left.id.compareTo(right.id) : order;
}

int _compareOffers(CatalogOffer left, CatalogOffer right) {
  final order = left.sortOrder.compareTo(right.sortOrder);
  return order == 0 ? left.id.compareTo(right.id) : order;
}
