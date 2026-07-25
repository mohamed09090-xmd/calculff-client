import 'package:calculff_client/app/routing/route_decision.dart';
import 'package:calculff_client/features/auth/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signed out redirects protected route to welcome', () {
    expect(
      RouteDecision.redirect(
        const AuthState(stage: AuthStage.signedOut),
        AppPaths.home,
      ),
      AppPaths.welcome,
    );
  });

  test('signed out may stay on login', () {
    expect(
      RouteDecision.redirect(
        const AuthState(stage: AuthStage.signedOut),
        AppPaths.login,
      ),
      isNull,
    );
  });

  test('unconfirmed user goes to verification', () {
    expect(
      RouteDecision.redirect(
        const AuthState(stage: AuthStage.emailUnconfirmed),
        AppPaths.login,
      ),
      AppPaths.verifyEmail,
    );
  });

  test('confirmed user goes to home', () {
    expect(
      RouteDecision.redirect(
        const AuthState(stage: AuthStage.authenticated),
        AppPaths.login,
      ),
      AppPaths.home,
    );
  });

  test('recovery goes to reset password', () {
    expect(
      RouteDecision.redirect(
        const AuthState(stage: AuthStage.passwordRecovery),
        AppPaths.home,
      ),
      AppPaths.resetPassword,
    );
  });

  test('missing configuration goes to setup', () {
    expect(
      RouteDecision.redirect(
        const AuthState(stage: AuthStage.configMissing),
        AppPaths.welcome,
      ),
      AppPaths.setup,
    );
  });

  test('logout state prevents navigation loop', () {
    const state = AuthState(stage: AuthStage.signedOut);
    expect(RouteDecision.redirect(state, AppPaths.welcome), isNull);
    expect(RouteDecision.redirect(state, AppPaths.profile), AppPaths.welcome);
  });
}
