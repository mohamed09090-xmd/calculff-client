import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/runtime/client_runtime_bootstrap.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';
import 'auth_error_mapper.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController({required ClientRuntimeBootstrap runtimeBootstrap})
      : _runtimeBootstrap = runtimeBootstrap,
        super(const AuthState.initializing());

  final ClientRuntimeBootstrap _runtimeBootstrap;
  AuthRepository? _repository;
  StreamSubscription<AuthEventSnapshot>? _subscription;
  Timer? _cooldownTimer;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    state = const AuthState.initializing();
    final result = await _runtimeBootstrap.initialize();
    switch (result.status) {
      case RuntimeBootstrapStatus.configMissing:
        state = const AuthState(stage: AuthStage.configMissing);
        return;
      case RuntimeBootstrapStatus.invalidConfiguration:
        state = const AuthState(
          stage: AuthStage.recoverableError,
          failure: AuthFailure(AuthFailureType.invalidConfiguration),
        );
        return;
      case RuntimeBootstrapStatus.failed:
        state = const AuthState(stage: AuthStage.recoverableError);
        return;
      case RuntimeBootstrapStatus.available:
        break;
    }
    final repository = result.repository;
    if (repository == null) {
      state = const AuthState(stage: AuthStage.recoverableError);
      return;
    }
    _repository = repository;
    _subscription = repository.authEvents.listen(_onAuthEvent);
    final session = repository.currentSession;
    if (session == null) {
      state = const AuthState(stage: AuthStage.signedOut);
    } else {
      await _applySession(session);
    }
  }

  Future<void> retryInitialization() async {
    _initialized = false;
    await _subscription?.cancel();
    _subscription = null;
    await initialize();
  }

  Future<void> signIn(String email, String password) async {
    final repository = _repository;
    if (repository == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, clearFailure: true);
    try {
      final session = await repository.signIn(email: email, password: password);
      await _applySession(session);
    } catch (error) {
      state = AuthState(
        stage: AuthStage.signedOut,
        failure: AuthErrorMapper.map(error),
      );
    }
  }

  Future<void> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String locale,
  }) async {
    final repository = _repository;
    if (repository == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, clearFailure: true);
    try {
      final result = await repository.signUp(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        locale: locale,
      );
      if (result.disposition == SignUpDisposition.confirmationRequired) {
        state = AuthState(
          stage: AuthStage.emailUnconfirmed,
          email: result.email,
        );
      } else if (result.session != null) {
        await _applySession(result.session!);
      }
    } catch (error) {
      state = AuthState(
        stage: AuthStage.signedOut,
        failure: AuthErrorMapper.map(error),
      );
    }
  }

  Future<void> resendConfirmation() async {
    final repository = _repository;
    final email = state.email ?? state.session?.email;
    if (repository == null || email == null || state.isBusy) return;
    if (state.resendCooldownSeconds > 0) return;
    state = state.copyWith(isBusy: true, clearFailure: true);
    try {
      await repository.resendConfirmation(email);
      state = state.copyWith(isBusy: false, resendCooldownSeconds: 60);
      _startCooldown();
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        failure: AuthErrorMapper.map(error),
      );
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resendCooldownSeconds - 1;
      if (next <= 0) timer.cancel();
      state = state.copyWith(
        resendCooldownSeconds: next.clamp(0, 60).toInt(),
      );
    });
  }

  Future<void> checkVerification() async {
    final repository = _repository;
    if (repository == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, clearFailure: true);
    try {
      final session = await repository.refreshSession();
      if (session == null) {
        state = state.copyWith(isBusy: false);
      } else {
        await _applySession(session);
      }
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        failure: AuthErrorMapper.map(error),
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final repository = _repository;
    if (repository == null || state.isBusy) return;
    state = state.copyWith(
      isBusy: true,
      clearFailure: true,
      recoveryRequestSent: false,
    );
    try {
      await repository.requestPasswordReset(email);
      state = state.copyWith(isBusy: false, recoveryRequestSent: true);
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        failure: AuthErrorMapper.map(error),
      );
    }
  }

  Future<void> updatePassword(String password) async {
    final repository = _repository;
    if (repository == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, clearFailure: true);
    try {
      await repository.updatePassword(password);
      final session = repository.currentSession;
      if (session == null) {
        state = const AuthState(stage: AuthStage.signedOut);
      } else {
        await _applySession(session);
      }
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        failure: AuthErrorMapper.map(error),
      );
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String locale,
  }) async {
    final repository = _repository;
    final session = state.session;
    if (repository == null || session == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, clearFailure: true);
    try {
      final profile = await repository.updateProfile(
        userId: session.userId,
        fullName: fullName,
        phone: phone,
        locale: locale,
      );
      state = state.copyWith(profile: profile, isBusy: false);
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        failure: AuthErrorMapper.map(error),
      );
    }
  }

  Future<void> signOut() async {
    final repository = _repository;
    if (repository == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, clearFailure: true);
    try {
      await repository.signOut();
    } catch (_) {
      await repository.clearLocalState();
    } finally {
      state = const AuthState(stage: AuthStage.signedOut);
    }
  }

  void clearFailure() => state = state.copyWith(clearFailure: true);

  Future<void> _onAuthEvent(AuthEventSnapshot event) async {
    if (event.signal == AuthSignal.signedOut) {
      state = const AuthState(stage: AuthStage.signedOut);
      return;
    }
    if (event.signal == AuthSignal.passwordRecovery) {
      state = AuthState(
        stage: AuthStage.passwordRecovery,
        session: event.session,
        email: event.session?.email,
      );
      return;
    }
    final session = event.session;
    if (session != null) await _applySession(session);
  }

  Future<void> _applySession(AuthSessionInfo session) async {
    final repository = _repository;
    if (!session.emailConfirmed) {
      state = AuthState(
        stage: AuthStage.emailUnconfirmed,
        session: session,
        email: session.email,
      );
      return;
    }
    ClientProfile? profile;
    try {
      profile = await repository?.completePendingProfile(session.userId) ??
          await repository?.fetchProfile(session.userId);
    } catch (_) {
      profile = await repository?.fetchProfile(session.userId);
    }
    state = AuthState(
      stage: AuthStage.authenticated,
      session: session,
      profile: profile,
      email: session.email,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
