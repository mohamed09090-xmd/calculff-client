import '../domain/catalog_game.dart';
import '../domain/catalog_offer.dart';
import 'catalog_payload_reader.dart';

class CatalogGameDto {
  const CatalogGameDto({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.nameFr,
    required this.rewardUnitCode,
    required this.rewardUnitNameAr,
    required this.rewardUnitNameFr,
    required this.isActive,
    required this.sortOrder,
  });

  factory CatalogGameDto.fromMap(Map<String, Object?> payload) {
    final reader = CatalogPayloadReader(payload);
    return CatalogGameDto(
      id: reader.requiredUuid('id'),
      slug: reader.requiredString('slug', maxLength: 64),
      nameAr: reader.requiredString('name_ar'),
      nameFr: reader.requiredString('name_fr'),
      rewardUnitCode: reader.requiredString('reward_unit_code', maxLength: 32),
      rewardUnitNameAr: reader.requiredString('reward_unit_name_ar'),
      rewardUnitNameFr: reader.requiredString('reward_unit_name_fr'),
      isActive: reader.requiredBool('is_active'),
      sortOrder: reader.requiredInt('sort_order', minimum: 0),
    );
  }

  final String id;
  final String slug;
  final String nameAr;
  final String nameFr;
  final String rewardUnitCode;
  final String rewardUnitNameAr;
  final String rewardUnitNameFr;
  final bool isActive;
  final int sortOrder;

  CatalogGame toDomain() {
    return CatalogGame(
      id: id,
      slug: slug,
      nameAr: nameAr,
      nameFr: nameFr,
      rewardUnitCode: rewardUnitCode,
      rewardUnitNameAr: rewardUnitNameAr,
      rewardUnitNameFr: rewardUnitNameFr,
      isActive: isActive,
      sortOrder: sortOrder,
    );
  }
}

class CatalogOfferDto {
  const CatalogOfferDto({
    required this.id,
    required this.gameId,
    required this.nameAr,
    required this.nameFr,
    required this.rewardQuantity,
    required this.salePriceDzd,
    required this.isPublished,
    required this.sortOrder,
  });

  factory CatalogOfferDto.fromMap(Map<String, Object?> payload) {
    final reader = CatalogPayloadReader(payload);
    return CatalogOfferDto(
      id: reader.requiredUuid('id'),
      gameId: reader.requiredUuid('game_id'),
      nameAr: reader.requiredString('name_ar'),
      nameFr: reader.requiredString('name_fr'),
      rewardQuantity: reader.requiredInt('reward_quantity', minimum: 1),
      salePriceDzd: reader.requiredInt('sale_price_dzd', minimum: 1),
      isPublished: reader.requiredBool('is_published'),
      sortOrder: reader.requiredInt('sort_order', minimum: 0),
    );
  }

  final String id;
  final String gameId;
  final String nameAr;
  final String nameFr;
  final int rewardQuantity;
  final int salePriceDzd;
  final bool isPublished;
  final int sortOrder;

  CatalogOffer toDomain() {
    return CatalogOffer(
      id: id,
      gameId: gameId,
      nameAr: nameAr,
      nameFr: nameFr,
      rewardQuantity: rewardQuantity,
      salePriceDzd: salePriceDzd,
      isPublished: isPublished,
      sortOrder: sortOrder,
    );
  }
}
