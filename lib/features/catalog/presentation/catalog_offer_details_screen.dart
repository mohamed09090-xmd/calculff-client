import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../../l10n/generated/app_localizations.dart';
import 'catalog_navigation.dart';

class CatalogOfferDetailsScreen extends StatelessWidget {
  const CatalogOfferDetailsScreen({required this.data, super.key});

  final CatalogOfferRouteData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    final formatter = NumberFormat.decimalPattern(locale.toLanguageTag());
    final offer = data.offer;
    final game = data.game;
    final offerName = offer.localizedName(languageCode);
    final gameName = game.localizedName(languageCode);
    final unit = game.localizedRewardUnitName(languageCode);
    final quantity = formatter.format(offer.rewardQuantity);
    final price = formatter.format(offer.salePriceDzd);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.offerDetailsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Semantics(
              header: true,
              child: Text(
                offerName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.sports_esports_outlined,
                      label: l10n.gameLabel,
                      value: gameName,
                    ),
                    const Divider(height: 28),
                    _DetailRow(
                      icon: Icons.diamond_outlined,
                      label: l10n.rewardLabel,
                      value: l10n.rewardAmount(quantity, unit),
                    ),
                    const Divider(height: 28),
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      label: l10n.priceLabel,
                      value: l10n.priceDzd(price),
                      forceLtrValue: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              label: l10n.catalogReadOnlyNotice,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l10n.catalogReadOnlyNotice)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.forceLtrValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool forceLtrValue;

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      style: Theme.of(context).textTheme.titleMedium,
      textAlign: TextAlign.end,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: forceLtrValue
              ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: valueWidget,
                )
              : valueWidget,
        ),
      ],
    );
  }
}

class CatalogRouteErrorScreen extends StatelessWidget {
  const CatalogRouteErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogUnavailableTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.link_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(l10n.catalogUnavailableBody, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(l10n.back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
