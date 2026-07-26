import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../../app/routing/route_decision.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/catalog_providers.dart';
import '../domain/catalog_game.dart';
import '../domain/catalog_offer.dart';
import 'catalog_list_view.dart';
import 'catalog_navigation.dart';

class CatalogOffersScreen extends ConsumerWidget {
  const CatalogOffersScreen({required this.game, super.key});

  final CatalogGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    final formatter = NumberFormat.decimalPattern(locale.toLanguageTag());
    final state = ref.watch(catalogOffersControllerProvider(game));
    final controller = ref.read(catalogOffersControllerProvider(game).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(game.localizedName(languageCode))),
      body: SafeArea(
        child: CatalogListView<CatalogOffer>(
          state: state,
          onRefresh: controller.refresh,
          onRetry: controller.retry,
          emptyTitle: l10n.noOffersTitle,
          emptyBody: l10n.noOffersBody,
          semanticsLabel: l10n.semanticsCatalogOffers,
          itemBuilder: (context, offer) {
            final offerName = offer.localizedName(languageCode);
            final unit = game.localizedRewardUnitName(languageCode);
            final quantity = formatter.format(offer.rewardQuantity);
            final price = formatter.format(offer.salePriceDzd);
            return Semantics(
              button: true,
              label: l10n.openOfferDetails(offerName),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push(
                    AppPaths.catalogOfferDetails(game.id, offer.id),
                    extra: CatalogOfferRouteData(game: game, offer: offer),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_offer_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                offerName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Text(l10n.rewardAmount(quantity, unit)),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                l10n.priceDzd(price),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
