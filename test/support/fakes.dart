import 'dart:async';

import 'package:calculff_client/app/runtime/client_runtime_bootstrap.dart';
import 'package:calculff_client/features/auth/application/auth_controller.dart';
import 'package:calculff_client/features/auth/domain/auth_models.dart';
import 'package:calculff_client/features/auth/domain/auth_repository.dart';

class FakeRuntimeBootstrap implements ClientRuntimeBootstrap {
  FakeRuntimeBootstrap(this.result);

  final RuntimeBootstrapResult result;

  @override
  Future<RuntimeBootstrapResult> initialize() async => result;
}

class FakeAuthRepository implements AuthRepository {
  final events = StreamController<AuthEventSnapshot>.broadcast();
  AuthSessionInfo? session;
  ClientProfile? profile;
  AuthFailure? signInFailure;
  SignUpResult? signUpResult;
  int signInCalls = 0;
  int signOutCalls = 0;
  int clearCalls = 0;
  int resetCalls = 0;

  @override
  Stream<AuthEventSnapshot> get authEvents => events.stream;

  @override
  AuthSessionInfo? get currentSession => session;

  @override
  Future<AuthSessionInfo> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (signInFailure != null) throw Exception(signInFailure!.type.name);
    return session ??
        const AuthSessionInfo(
          userId: 'user-1',
          email: 'client@example.com',
          emailConfirmed: true,
        );
  }

  @override
  Future<SignUpResult> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String locale,
  }) async {
    return signUpResult ??
        SignUpResult(
          disposition: SignUpDisposition.confirmationRequired,
          email: email,
        );
  }

  @override
  Future<void> resendConfirmation(String email) async {}

  @override
  Future<AuthSessionInfo?> refreshSession() async => session;

  @override
  Future<void> requestPasswordReset(String email) async {
    resetCalls++;
  }

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> signOut() async {
    signOutCalls++;
    session = null;
    clearCalls++;
  }

  @override
  Future<void> clearLocalState() async {
    clearCalls++;
  }

  @override
  Future<ClientProfile?> fetchProfile(String userId) async => profile;

  @override
  Future<ClientProfile?> completePendingProfile(String userId) async => profile;

  @override
  Future<ClientProfile> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String locale,
  }) async {
    profile = ClientProfile(
      id: userId,
      email: session?.email ?? 'client@example.com',
      fullName: fullName,
      phone: phone,
      locale: locale,
    );
    return profile!;
  }

  Future<void> dispose() => events.close();
}

class TestAuthController extends AuthController {
  TestAuthController(AuthState initial)
    : super(
        runtimeBootstrap: FakeRuntimeBootstrap(
          const RuntimeBootstrapResult.configMissing(),
        ),
      ) {
    state = initial;
  }

  int signInInvocations = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> signIn(String email, String password) async {
    signInInvocations++;
  }
}
