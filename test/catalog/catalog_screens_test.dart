import 'package:calculff_client/app/routing/route_decision.dart';
import 'package:calculff_client/features/auth/application/auth_providers.dart';
import 'package:calculff_client/features/auth/domain/auth_models.dart';
import 'package:calculff_client/features/catalog/application/catalog_controller.dart';
import 'package:calculff_client/features/catalog/application/catalog_providers.dart';
import 'package:calculff_client/features/catalog/application/catalog_state.dart';
import 'package:calculff_client/features/catalog/domain/catalog_failure.dart';
import 'package:calculff_client/features/catalog/domain/catalog_game.dart';
import 'package:calculff_client/features/catalog/domain/catalog_offer.dart';
import 'package:calculff_client/features/catalog/presentation/catalog_games_screen.dart';
import 'package:calculff_client/features/catalog/presentation/catalog_navigation.dart';
import 'package:calculff_client/features/catalog/presentation/catalog_offer_details_screen.dart';
import 'package:calculff_client/features/catalog/presentation/catalog_offers_screen.dart';
import 'package:calculff_client/features/home/presentation/home_screen.dart';
import 'package:calculff_client/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/fakes.dart';

const game = CatalogGame(
  id: '11111111-1111-4111-8111-111111111111',
  slug: 'free-fire',
  nameAr: 'فري فاير',
  nameFr: 'Free Fire',
  rewardUnitCode: 'diamonds',
  rewardUnitNameAr: 'جواهر',
  rewardUnitNameFr: 'Diamants',
  isActive: true,
  sortOrder: 0,
);

const offer = CatalogOffer(
  id: '33333333-3333-4333-8333-333333333333',
  gameId: '11111111-1111-4111-8111-111111111111',
  nameAr: 'عرض 100 جوهرة',
  nameFr: 'Offre 100 diamants',
  rewardQuantity: 100,
  salePriceDzd: 240,
  isPublished: true,
  sortOrder: 0,
);

class FixedCatalogController<T> extends CatalogController<T> {
  FixedCatalogController(CatalogListState<T> initial)
    : super(loader: () async => initial.items, onSessionExpired: () async {}) {
    state = initial;
  }

  int retryCalls = 0;
  int refreshCalls = 0;

  @override
  Future<void> retry() async {
    retryCalls++;
  }

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }
}

Future<void> pumpGames(
  WidgetTester tester,
  FixedCatalogController<CatalogGame> controller, {
  Locale locale = const Locale('ar'),
  Size? size,
  double textScale = 1,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        catalogGamesControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const CatalogGamesScreen(),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> pumpOffers(
  WidgetTester tester,
  FixedCatalogController<CatalogOffer> controller, {
  Locale locale = const Locale('ar'),
  Size? size,
  double textScale = 1,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        catalogOffersControllerProvider.overrideWith(
          (ref, requestedGame) => controller,
        ),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const CatalogOffersScreen(game: game),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('games render Arabic RTL and French LTR text', (tester) async {
    final controller = FixedCatalogController<CatalogGame>(
      const CatalogListState(
        status: CatalogLoadStatus.data,
        items: [game],
      ),
    );
    addTearDown(controller.dispose);
    await pumpGames(tester, controller);
    expect(find.text('فري فاير'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('فري فاير'))),
      TextDirection.rtl,
    );

    await pumpGames(tester, controller, locale: const Locale('fr'));
    expect(find.text('Free Fire'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Free Fire'))),
      TextDirection.ltr,
    );
  });

  testWidgets('loading, empty, error and retry states render', (tester) async {
    final loading = FixedCatalogController<CatalogGame>(
      const CatalogListState(status: CatalogLoadStatus.loading),
    );
    addTearDown(loading.dispose);
    await pumpGames(tester, loading);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final empty = FixedCatalogController<CatalogGame>(
      const CatalogListState(status: CatalogLoadStatus.empty),
    );
    addTearDown(empty.dispose);
    await pumpGames(tester, empty);
    expect(find.text('لا توجد ألعاب متاحة'), findsOneWidget);

    final failed = FixedCatalogController<CatalogGame>(
      const CatalogListState(
        status: CatalogLoadStatus.failure,
        failure: CatalogFailure(CatalogFailureType.networkUnavailable),
      ),
    );
    addTearDown(failed.dispose);
    await pumpGames(tester, failed);
    expect(find.textContaining('اتصال الإنترنت'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    expect(failed.retryCalls, 1);
  });

  testWidgets('offers support small screens and large text', (tester) async {
    final controller = FixedCatalogController<CatalogOffer>(
      const CatalogListState(
        status: CatalogLoadStatus.data,
        items: [offer],
      ),
    );
    addTearDown(controller.dispose);
    await pumpOffers(
      tester,
      controller,
      size: const Size(320, 568),
      textScale: 2,
    );

    expect(find.text('عرض 100 جوهرة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offer details expose public data only', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: CatalogOfferDetailsScreen(
          data: CatalogOfferRouteData(game: game, offer: offer),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('فري فاير'), findsOneWidget);
    expect(find.textContaining('100'), findsWidgets);
    expect(find.textContaining('240'), findsOneWidget);
    expect(find.textContaining('999'), findsNothing);
    expect(find.textContaining('مخزون'), findsNothing);
    expect(find.textContaining('ربح'), findsNothing);
    expect(find.textContaining('تكلفة'), findsNothing);
  });

  testWidgets('home navigates to games then offers', (tester) async {
    final authController = TestAuthController(
      const AuthState(
        stage: AuthStage.authenticated,
        session: AuthSessionInfo(
          userId: 'user-1',
          email: 'client@example.com',
          emailConfirmed: true,
        ),
      ),
    );
    final gamesController = FixedCatalogController<CatalogGame>(
      const CatalogListState(
        status: CatalogLoadStatus.data,
        items: [game],
      ),
    );
    final offersController = FixedCatalogController<CatalogOffer>(
      const CatalogListState(
        status: CatalogLoadStatus.data,
        items: [offer],
      ),
    );
    addTearDown(authController.dispose);
    addTearDown(gamesController.dispose);
    addTearDown(offersController.dispose);

    final router = GoRouter(
      initialLocation: AppPaths.home,
      routes: [
        GoRoute(
          path: AppPaths.home,
          builder: (_, _) => const HomeScreen(),
        ),
        GoRoute(
          path: AppPaths.catalog,
          builder: (_, _) => const CatalogGamesScreen(),
        ),
        GoRoute(
          path: '${AppPaths.catalog}/games/:gameId/offers',
          builder: (_, state) => CatalogOffersScreen(
            game: state.extra! as CatalogGame,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => authController),
          catalogGamesControllerProvider.overrideWith(
            (ref) => gamesController,
          ),
          catalogOffersControllerProvider.overrideWith(
            (ref, requestedGame) => offersController,
          ),
        ],
        child: MaterialApp.router(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('تصفح الألعاب والعروض'));
    await tester.pumpAndSettle();
    expect(find.text('فري فاير'), findsOneWidget);

    await tester.tap(find.text('فري فاير'));
    await tester.pumpAndSettle();
    expect(find.text('عرض 100 جوهرة'), findsOneWidget);
  });
}
