enum AuthStage {
  configMissing,
  initializing,
  signedOut,
  emailUnconfirmed,
  authenticated,
  passwordRecovery,
  recoverableError,
}

enum AuthFailureType {
  invalidCredentials,
  emailNotConfirmed,
  networkUnavailable,
  tooManyRequests,
  invalidConfiguration,
  temporary,
}

class AuthFailure {
  const AuthFailure(this.type);

  final AuthFailureType type;
}

class AuthSessionInfo {
  const AuthSessionInfo({
    required this.userId,
    required this.email,
    required this.emailConfirmed,
  });

  final String userId;
  final String email;
  final bool emailConfirmed;
}

class ClientProfile {
  const ClientProfile({
    required this.id,
    required this.email,
    required this.locale,
    this.fullName,
    this.phone,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String locale;

  String get displayName {
    final value = fullName?.trim();
    return value == null || value.isEmpty ? email : value;
  }
}

enum AuthSignal {
  initialSession,
  signedIn,
  signedOut,
  passwordRecovery,
  tokenRefreshed,
  userUpdated,
  unknown,
}

class AuthEventSnapshot {
  const AuthEventSnapshot({required this.signal, this.session});

  final AuthSignal signal;
  final AuthSessionInfo? session;
}

enum SignUpDisposition { signedIn, confirmationRequired }

class SignUpResult {
  const SignUpResult({
    required this.disposition,
    required this.email,
    this.session,
  });

  final SignUpDisposition disposition;
  final String email;
  final AuthSessionInfo? session;
}

class PendingProfile {
  const PendingProfile({
    required this.fullName,
    required this.phone,
    required this.locale,
  });

  final String fullName;
  final String phone;
  final String locale;
}

class AuthState {
  const AuthState({
    required this.stage,
    this.session,
    this.profile,
    this.email,
    this.failure,
    this.isBusy = false,
    this.recoveryRequestSent = false,
    this.resendCooldownSeconds = 0,
    this.notice,
  });

  const AuthState.initializing() : this(stage: AuthStage.initializing);

  final AuthStage stage;
  final AuthSessionInfo? session;
  final ClientProfile? profile;
  final String? email;
  final AuthFailure? failure;
  final bool isBusy;
  final bool recoveryRequestSent;
  final int resendCooldownSeconds;
  final String? notice;

  AuthState copyWith({
    AuthStage? stage,
    AuthSessionInfo? session,
    ClientProfile? profile,
    String? email,
    AuthFailure? failure,
    bool clearFailure = false,
    bool? isBusy,
    bool? recoveryRequestSent,
    int? resendCooldownSeconds,
    String? notice,
    bool clearNotice = false,
    bool clearProfile = false,
  }) {
    return AuthState(
      stage: stage ?? this.stage,
      session: session ?? this.session,
      profile: clearProfile ? null : profile ?? this.profile,
      email: email ?? this.email,
      failure: clearFailure ? null : failure ?? this.failure,
      isBusy: isBusy ?? this.isBusy,
      recoveryRequestSent: recoveryRequestSent ?? this.recoveryRequestSent,
      resendCooldownSeconds:
          resendCooldownSeconds ?? this.resendCooldownSeconds,
      notice: clearNotice ? null : notice ?? this.notice,
    );
  }
}
