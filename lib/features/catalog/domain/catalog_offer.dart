class CatalogOffer {
  const CatalogOffer({
    required this.id,
    required this.gameId,
    required this.nameAr,
    required this.nameFr,
    required this.rewardQuantity,
    required this.salePriceDzd,
    required this.isPublished,
    required this.sortOrder,
  });

  final String id;
  final String gameId;
  final String nameAr;
  final String nameFr;
  final int rewardQuantity;
  final int salePriceDzd;
  final bool isPublished;
  final int sortOrder;

  String localizedName(String languageCode) {
    return languageCode == 'fr' ? nameFr : nameAr;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogOffer &&
            other.id == id &&
            other.gameId == gameId &&
            other.nameAr == nameAr &&
            other.nameFr == nameFr &&
            other.rewardQuantity == rewardQuantity &&
            other.salePriceDzd == salePriceDzd &&
            other.isPublished == isPublished &&
            other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    nameAr,
    nameFr,
    rewardQuantity,
    salePriceDzd,
    isPublished,
    sortOrder,
  );
}
