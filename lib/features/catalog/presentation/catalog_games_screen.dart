import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/route_decision.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/catalog_providers.dart';
import '../domain/catalog_game.dart';
import 'catalog_list_view.dart';

class CatalogGamesScreen extends ConsumerWidget {
  const CatalogGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(catalogGamesControllerProvider);
    final languageCode = Localizations.localeOf(context).languageCode;
    final controller = ref.read(catalogGamesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      body: SafeArea(
        child: CatalogListView<CatalogGame>(
          state: state,
          onRefresh: controller.refresh,
          onRetry: controller.retry,
          emptyTitle: l10n.noGamesTitle,
          emptyBody: l10n.noGamesBody,
          semanticsLabel: l10n.semanticsCatalogGames,
          itemBuilder: (context, game) {
            final name = game.localizedName(languageCode);
            final unit = game.localizedRewardUnitName(languageCode);
            return Semantics(
              button: true,
              label: l10n.openGameOffers(name),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push(
                    AppPaths.catalogOffers(game.id),
                    extra: game,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_esports_outlined, size: 34),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(l10n.rewardUnitLabel(unit)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
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
