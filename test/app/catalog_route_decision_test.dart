import 'package:calculff_client/app/routing/route_decision.dart';
import 'package:calculff_client/features/auth/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authenticated users may open every catalog route', () {
    const auth = AuthState(stage: AuthStage.authenticated);
    expect(RouteDecision.redirect(auth, AppPaths.catalog), isNull);
    expect(
      RouteDecision.redirect(
        auth,
        AppPaths.catalogOffers('11111111-1111-4111-8111-111111111111'),
      ),
      isNull,
    );
    expect(
      RouteDecision.redirect(
        auth,
        AppPaths.catalogOfferDetails(
          '11111111-1111-4111-8111-111111111111',
          '33333333-3333-4333-8333-333333333333',
        ),
      ),
      isNull,
    );
  });

  test('logout closes every protected catalog route', () {
    const signedOut = AuthState(stage: AuthStage.signedOut);
    expect(
      RouteDecision.redirect(signedOut, AppPaths.catalog),
      AppPaths.welcome,
    );
    expect(
      RouteDecision.redirect(
        signedOut,
        AppPaths.catalogOffers('11111111-1111-4111-8111-111111111111'),
      ),
      AppPaths.welcome,
    );
  });
}
