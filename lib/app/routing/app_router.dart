import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/domain/auth_models.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/catalog/domain/catalog_game.dart';
import '../../features/catalog/presentation/catalog_games_screen.dart';
import '../../features/catalog/presentation/catalog_navigation.dart';
import '../../features/catalog/presentation/catalog_offer_details_screen.dart';
import '../../features/catalog/presentation/catalog_offers_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import 'route_decision.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final controller = ref.read(authControllerProvider.notifier);
  final refresh = AuthRouterRefresh(controller.stream);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppPaths.bootstrap,
    refreshListenable: refresh,
    redirect: (context, state) {
      return RouteDecision.redirect(
        ref.read(authControllerProvider),
        state.uri.path,
      );
    },
    routes: [
      GoRoute(
        path: AppPaths.bootstrap,
        builder: (context, state) => const BootstrapScreen(),
      ),
      GoRoute(
        path: AppPaths.setup,
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: AppPaths.startupError,
        builder: (context, state) => const BootstrapErrorScreen(),
      ),
      GoRoute(
        path: AppPaths.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppPaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppPaths.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppPaths.verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppPaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppPaths.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppPaths.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppPaths.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppPaths.catalog,
        builder: (context, state) => const CatalogGamesScreen(),
      ),
      GoRoute(
        path: '${AppPaths.catalog}/games/:gameId/offers',
        builder: (context, state) {
          final game = state.extra;
          if (game is! CatalogGame ||
              game.id != state.pathParameters['gameId']) {
            return const CatalogRouteErrorScreen();
          }
          return CatalogOffersScreen(game: game);
        },
      ),
      GoRoute(
        path: '${AppPaths.catalog}/games/:gameId/offers/:offerId',
        builder: (context, state) {
          final data = state.extra;
          if (data is! CatalogOfferRouteData ||
              data.game.id != state.pathParameters['gameId'] ||
              data.offer.id != state.pathParameters['offerId'] ||
              data.offer.gameId != data.game.id) {
            return const CatalogRouteErrorScreen();
          }
          return CatalogOfferDetailsScreen(data: data);
        },
      ),
    ],
  );
});

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
