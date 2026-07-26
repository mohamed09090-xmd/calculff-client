import 'package:calculff_client/features/catalog/domain/catalog_game.dart';
import 'package:calculff_client/features/catalog/infrastructure/catalog_dtos.dart';
import 'package:calculff_client/features/catalog/infrastructure/catalog_gateway.dart';
import 'package:calculff_client/features/catalog/infrastructure/catalog_payload_reader.dart';
import 'package:calculff_client/features/catalog/infrastructure/supabase_catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const gameId = '11111111-1111-4111-8111-111111111111';
const secondGameId = '22222222-2222-4222-8222-222222222222';
const offerId = '33333333-3333-4333-8333-333333333333';

Map<String, Object?> gameRow({
  String id = gameId,
  bool isActive = true,
  int sortOrder = 0,
}) {
  return <String, Object?>{
    'id': id,
    'slug': 'free-fire',
    'name_ar': 'فري فاير',
    'name_fr': 'Free Fire',
    'reward_unit_code': 'diamonds',
    'reward_unit_name_ar': 'جواهر',
    'reward_unit_name_fr': 'Diamants',
    'is_active': isActive,
    'sort_order': sortOrder,
    'internal_cost': 999,
  };
}

Map<String, Object?> offerRow({
  String id = offerId,
  String linkedGameId = gameId,
  bool isPublished = true,
  int sortOrder = 0,
}) {
  return <String, Object?>{
    'id': id,
    'game_id': linkedGameId,
    'name_ar': 'عرض 100 جوهرة',
    'name_fr': 'Offre 100 diamants',
    'reward_quantity': 100,
    'sale_price_dzd': 240,
    'is_published': isPublished,
    'sort_order': sortOrder,
    'profit_dzd': 999,
    'stock': 500,
  };
}

class FakeCatalogGateway implements CatalogGateway {
  List<Map<String, Object?>> games = <Map<String, Object?>>[];
  List<Map<String, Object?>> offers = <Map<String, Object?>>[];
  int gameCalls = 0;
  int offerCalls = 0;

  @override
  Future<List<Map<String, Object?>>> fetchActiveGames() async {
    gameCalls++;
    return games;
  }

  @override
  Future<List<Map<String, Object?>>> fetchPublishedOffers(String gameId) async {
    offerCalls++;
    return offers;
  }
}

void main() {
  group('catalog mapping', () {
    test('maps a game using the exact public contract', () {
      final game = CatalogGameDto.fromMap(gameRow()).toDomain();
      expect(game.id, gameId);
      expect(game.localizedName('ar'), 'فري فاير');
      expect(game.localizedName('fr'), 'Free Fire');
      expect(game.localizedRewardUnitName('ar'), 'جواهر');
      expect(game.localizedRewardUnitName('fr'), 'Diamants');
      expect(game.isActive, isTrue);
    });

    test('maps an offer using the exact public contract', () {
      final offer = CatalogOfferDto.fromMap(offerRow()).toDomain();
      expect(offer.id, offerId);
      expect(offer.gameId, gameId);
      expect(offer.localizedName('ar'), 'عرض 100 جوهرة');
      expect(offer.localizedName('fr'), 'Offre 100 diamants');
      expect(offer.rewardQuantity, 100);
      expect(offer.salePriceDzd, 240);
    });

    test('rejects missing required fields', () {
      final row = gameRow()..remove('name_ar');
      expect(
        () => CatalogGameDto.fromMap(row),
        throwsA(
          isA<CatalogPayloadException>()
              .having((error) => error.field, 'field', 'name_ar')
              .having(
                (error) => error.reason,
                'reason',
                CatalogPayloadFailureReason.missing,
              ),
        ),
      );
    });

    test('rejects fields with incorrect types', () {
      final row = offerRow()..['reward_quantity'] = '100';
      expect(
        () => CatalogOfferDto.fromMap(row),
        throwsA(
          isA<CatalogPayloadException>().having(
            (error) => error.reason,
            'reason',
            CatalogPayloadFailureReason.wrongType,
          ),
        ),
      );
    });

    test('rejects invalid UUIDs and non-positive values', () {
      expect(
        () => CatalogGameDto.fromMap(gameRow(id: 'not-a-uuid')),
        throwsA(isA<CatalogPayloadException>()),
      );
      final row = offerRow()..['sale_price_dzd'] = 0;
      expect(
        () => CatalogOfferDto.fromMap(row),
        throwsA(isA<CatalogPayloadException>()),
      );
    });
  });

  group('catalog repository', () {
    test('defensively filters inactive games and sorts stably', () async {
      final gateway = FakeCatalogGateway()
        ..games = [
          gameRow(id: secondGameId, sortOrder: 2),
          gameRow(isActive: false, sortOrder: 0),
          gameRow(sortOrder: 1),
        ];
      final repository = SupabaseCatalogRepository(gateway);

      final games = await repository.fetchActiveGames();

      expect(games.map((game) => game.id), [gameId, secondGameId]);
      expect(gateway.gameCalls, 1);
    });

    test('defensively filters unpublished and foreign offers', () async {
      final gateway = FakeCatalogGateway()
        ..offers = [
          offerRow(isPublished: false),
          offerRow(linkedGameId: secondGameId),
          offerRow(sortOrder: 2),
        ];
      final repository = SupabaseCatalogRepository(gateway);
      final game = CatalogGameDto.fromMap(gameRow()).toDomain();

      final offers = await repository.fetchPublishedOffers(game);

      expect(offers, hasLength(1));
      expect(offers.single.id, offerId);
      expect(gateway.offerCalls, 1);
    });

    test('does not query offers for an inactive game', () async {
      final gateway = FakeCatalogGateway();
      final repository = SupabaseCatalogRepository(gateway);
      final inactiveGame = CatalogGameDto.fromMap(
        gameRow(isActive: false),
      ).toDomain();

      expect(await repository.fetchPublishedOffers(inactiveGame), isEmpty);
      expect(gateway.offerCalls, 0);
    });

    test('ignores administrative fields from gateway rows', () async {
      final gateway = FakeCatalogGateway()
        ..games = [gameRow()]
        ..offers = [offerRow()];
      final repository = SupabaseCatalogRepository(gateway);
      final CatalogGame game = (await repository.fetchActiveGames()).single;
      final offer = (await repository.fetchPublishedOffers(game)).single;

      expect(game.localizedName('fr'), 'Free Fire');
      expect(offer.salePriceDzd, 240);
      expect(offer.rewardQuantity, 100);
    });
  });
}
