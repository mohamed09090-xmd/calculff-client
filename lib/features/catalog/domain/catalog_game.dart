class CatalogGame {
  const CatalogGame({
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

  final String id;
  final String slug;
  final String nameAr;
  final String nameFr;
  final String rewardUnitCode;
  final String rewardUnitNameAr;
  final String rewardUnitNameFr;
  final bool isActive;
  final int sortOrder;

  String localizedName(String languageCode) {
    return languageCode == 'fr' ? nameFr : nameAr;
  }

  String localizedRewardUnitName(String languageCode) {
    return languageCode == 'fr' ? rewardUnitNameFr : rewardUnitNameAr;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogGame &&
            other.id == id &&
            other.slug == slug &&
            other.nameAr == nameAr &&
            other.nameFr == nameFr &&
            other.rewardUnitCode == rewardUnitCode &&
            other.rewardUnitNameAr == rewardUnitNameAr &&
            other.rewardUnitNameFr == rewardUnitNameFr &&
            other.isActive == isActive &&
            other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(
    id,
    slug,
    nameAr,
    nameFr,
    rewardUnitCode,
    rewardUnitNameAr,
    rewardUnitNameFr,
    isActive,
    sortOrder,
  );
}
