import 'package:calculff_client/app/runtime/client_runtime_bootstrap.dart';
import 'package:calculff_client/features/auth/application/auth_controller.dart';
import 'package:calculff_client/features/auth/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  test('maps missing configuration to setup state', () async {
    final controller = AuthController(
      runtimeBootstrap: FakeRuntimeBootstrap(
        const RuntimeBootstrapResult.configMissing(),
      ),
    );
    await controller.initialize();
    expect(controller.state.stage, AuthStage.configMissing);
    controller.dispose();
  });

  test('restores signed-out session without login flash', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(
      runtimeBootstrap: FakeRuntimeBootstrap(
        RuntimeBootstrapResult.available(repository),
      ),
    );
    expect(controller.state.stage, AuthStage.initializing);
    await controller.initialize();
    expect(controller.state.stage, AuthStage.signedOut);
    controller.dispose();
    await repository.dispose();
  });

  test('maps unconfirmed session to verification', () async {
    final repository = FakeAuthRepository()
      ..session = const AuthSessionInfo(
        userId: 'user-1',
        email: 'client@example.com',
        emailConfirmed: false,
      );
    final controller = AuthController(
      runtimeBootstrap: FakeRuntimeBootstrap(
        RuntimeBootstrapResult.available(repository),
      ),
    );
    await controller.initialize();
    expect(controller.state.stage, AuthStage.emailUnconfirmed);
    controller.dispose();
    await repository.dispose();
  });

  test('maps confirmed session and profile to authenticated', () async {
    final repository = FakeAuthRepository()
      ..session = const AuthSessionInfo(
        userId: 'user-1',
        email: 'client@example.com',
        emailConfirmed: true,
      )
      ..profile = const ClientProfile(
        id: 'user-1',
        email: 'client@example.com',
        fullName: 'Client',
        phone: '+213555000000',
        locale: 'ar',
      );
    final controller = AuthController(
      runtimeBootstrap: FakeRuntimeBootstrap(
        RuntimeBootstrapResult.available(repository),
      ),
    );
    await controller.initialize();
    expect(controller.state.stage, AuthStage.authenticated);
    expect(controller.state.profile?.fullName, 'Client');
    controller.dispose();
    await repository.dispose();
  });

  test('password recovery event changes state', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(
      runtimeBootstrap: FakeRuntimeBootstrap(
        RuntimeBootstrapResult.available(repository),
      ),
    );
    await controller.initialize();
    repository.events.add(
      const AuthEventSnapshot(signal: AuthSignal.passwordRecovery),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.stage, AuthStage.passwordRecovery);
    controller.dispose();
    await repository.dispose();
  });

  test('logout clears profile state and local repository state', () async {
    final repository = FakeAuthRepository()
      ..session = const AuthSessionInfo(
        userId: 'user-1',
        email: 'client@example.com',
        emailConfirmed: true,
      );
    final controller = AuthController(
      runtimeBootstrap: FakeRuntimeBootstrap(
        RuntimeBootstrapResult.available(repository),
      ),
    );
    await controller.initialize();
    await controller.signOut();
    expect(controller.state.stage, AuthStage.signedOut);
    expect(controller.state.profile, isNull);
    expect(repository.signOutCalls, 1);
    expect(repository.clearCalls, 1);
    controller.dispose();
    await repository.dispose();
  });

  test('password reset request uses non-enumerating success state', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(
      runtimeBootstrap: FakeRuntimeBootstrap(
        RuntimeBootstrapResult.available(repository),
      ),
    );
    await controller.initialize();
    await controller.requestPasswordReset('client@example.com');
    expect(controller.state.recoveryRequestSent, isTrue);
    expect(repository.resetCalls, 1);
    controller.dispose();
    await repository.dispose();
  });
}
