import '../../features/auth/domain/auth_models.dart';

abstract final class AppPaths {
  static const bootstrap = '/bootstrap';
  static const setup = '/setup';
  static const startupError = '/startup-error';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const profile = '/profile';
  static const catalog = '/catalog';

  static String catalogOffers(String gameId) => '$catalog/games/$gameId/offers';

  static String catalogOfferDetails(String gameId, String offerId) {
    return '${catalogOffers(gameId)}/$offerId';
  }
}

abstract final class RouteDecision {
  static const _signedOutPaths = {
    AppPaths.welcome,
    AppPaths.login,
    AppPaths.signup,
    AppPaths.forgotPassword,
  };

  static const _authenticatedExactPaths = {
    AppPaths.home,
    AppPaths.profile,
    AppPaths.catalog,
  };

  static bool _isAuthenticatedPath(String location) {
    return _authenticatedExactPaths.contains(location) ||
        location.startsWith('${AppPaths.catalog}/');
  }

  static String? redirect(AuthState auth, String location) {
    return switch (auth.stage) {
      AuthStage.initializing =>
        location == AppPaths.bootstrap ? null : AppPaths.bootstrap,
      AuthStage.configMissing =>
        location == AppPaths.setup ? null : AppPaths.setup,
      AuthStage.recoverableError =>
        location == AppPaths.startupError ? null : AppPaths.startupError,
      AuthStage.passwordRecovery =>
        location == AppPaths.resetPassword ? null : AppPaths.resetPassword,
      AuthStage.emailUnconfirmed =>
        location == AppPaths.verifyEmail ? null : AppPaths.verifyEmail,
      AuthStage.signedOut =>
        _signedOutPaths.contains(location) ? null : AppPaths.welcome,
      AuthStage.authenticated =>
        _isAuthenticatedPath(location) ? null : AppPaths.home,
    };
  }
}
