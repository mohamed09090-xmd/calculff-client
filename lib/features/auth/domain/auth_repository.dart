import 'auth_models.dart';

abstract interface class AuthRepository {
  Stream<AuthEventSnapshot> get authEvents;
  AuthSessionInfo? get currentSession;

  Future<AuthSessionInfo> signIn({
    required String email,
    required String password,
  });

  Future<SignUpResult> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String locale,
  });

  Future<void> resendConfirmation(String email);
  Future<AuthSessionInfo?> refreshSession();
  Future<void> requestPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signOut();
  Future<ClientProfile?> fetchProfile(String userId);
  Future<ClientProfile?> completePendingProfile(String userId);
  Future<ClientProfile> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String locale,
  });
  Future<void> clearLocalState();
}
