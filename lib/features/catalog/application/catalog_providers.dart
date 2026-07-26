import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_models.dart';
import '../domain/catalog_game.dart';
import '../domain/catalog_offer.dart';
import '../domain/catalog_repository.dart';
import '../infrastructure/catalog_gateway.dart';
import '../infrastructure/supabase_catalog_gateway.dart';
import '../infrastructure/supabase_catalog_repository.dart';
import 'catalog_controller.dart';
import 'catalog_state.dart';

final catalogGatewayProvider = Provider<CatalogGateway>((ref) {
  return SupabaseCatalogGateway(Supabase.instance.client);
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return SupabaseCatalogRepository(ref.watch(catalogGatewayProvider));
});

final catalogGamesControllerProvider =
    StateNotifierProvider<
      CatalogController<CatalogGame>,
      CatalogListState<CatalogGame>
    >((ref) {
      final authStage = ref.watch(
        authControllerProvider.select((state) => state.stage),
      );
      final repository = ref.watch(catalogRepositoryProvider);
      final controller = CatalogController<CatalogGame>(
        loader: repository.fetchActiveGames,
        onSessionExpired: ref.read(authControllerProvider.notifier).signOut,
      );
      if (authStage == AuthStage.authenticated) {
        Future.microtask(controller.load);
      }
      return controller;
    });

final catalogOffersControllerProvider =
    StateNotifierProvider.family<
      CatalogController<CatalogOffer>,
      CatalogListState<CatalogOffer>,
      CatalogGame
    >((ref, game) {
      final authStage = ref.watch(
        authControllerProvider.select((state) => state.stage),
      );
      final repository = ref.watch(catalogRepositoryProvider);
      final controller = CatalogController<CatalogOffer>(
        loader: () => repository.fetchPublishedOffers(game),
        onSessionExpired: ref.read(authControllerProvider.notifier).signOut,
      );
      if (authStage == AuthStage.authenticated) {
        Future.microtask(controller.load);
      }
      return controller;
    });
