import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/security/secure_supabase_local_storage.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';
import 'pending_profile_store.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required SupabaseClient client,
    required SecureSupabaseLocalStorage localStorage,
    required PendingProfileStore pendingProfileStore,
  })  : _client = client,
        _localStorage = localStorage,
        _pendingProfileStore = pendingProfileStore;

  static const redirectUrl = 'calculffclient://auth-callback';

  final SupabaseClient _client;
  final SecureSupabaseLocalStorage _localStorage;
  final PendingProfileStore _pendingProfileStore;

  @override
  Stream<AuthEventSnapshot> get authEvents =>
      _client.auth.onAuthStateChange.map((event) {
        return AuthEventSnapshot(
          signal: _mapSignal(event.event),
          session: _mapSession(event.session),
        );
      });

  @override
  AuthSessionInfo? get currentSession => _mapSession(_client.auth.currentSession);

  @override
  Future<AuthSessionInfo> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final session = _mapSession(response.session);
    if (session == null) {
      throw const AuthException('A session was not returned.');
    }
    return session;
  }

  @override
  Future<SignUpResult> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String locale,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    await _pendingProfileStore.save(
      PendingProfile(
        fullName: fullName.trim(),
        phone: phone.trim(),
        locale: locale,
      ),
    );
    try {
      final response = await _client.auth.signUp(
        email: normalizedEmail,
        password: password,
        emailRedirectTo: redirectUrl,
      );
      final session = _mapSession(response.session);
      if (session != null) {
        await completePendingProfile(session.userId);
        return SignUpResult(
          disposition: SignUpDisposition.signedIn,
          email: normalizedEmail,
          session: session,
        );
      }
      return SignUpResult(
        disposition: SignUpDisposition.confirmationRequired,
        email: normalizedEmail,
      );
    } catch (_) {
      await _pendingProfileStore.clear();
      rethrow;
    }
  }

  @override
  Future<void> resendConfirmation(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email.trim().toLowerCase(),
      emailRedirectTo: redirectUrl,
    );
  }

  @override
  Future<AuthSessionInfo?> refreshSession() async {
    final response = await _client.auth.refreshSession();
    return _mapSession(response.session);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(
      email.trim().toLowerCase(),
      redirectTo: redirectUrl,
    );
  }

  @override
  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    await clearLocalState();
  }

  @override
  Future<void> clearLocalState() async {
    await _localStorage.removePersistedSession();
    await _pendingProfileStore.clear();
  }

  @override
  Future<ClientProfile?> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select('id,email,full_name,phone,locale')
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return _mapProfile(row);
  }

  @override
  Future<ClientProfile?> completePendingProfile(String userId) async {
    final pending = await _pendingProfileStore.read();
    if (pending == null) return fetchProfile(userId);
    final profile = await updateProfile(
      userId: userId,
      fullName: pending.fullName,
      phone: pending.phone,
      locale: pending.locale,
    );
    await _pendingProfileStore.clear();
    return profile;
  }

  @override
  Future<ClientProfile> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String locale,
  }) async {
    final row = await _client
        .from('profiles')
        .update({
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'locale': locale,
        })
        .eq('id', userId)
        .select('id,email,full_name,phone,locale')
        .single();
    return _mapProfile(row);
  }

  ClientProfile _mapProfile(Map<String, dynamic> row) {
    return ClientProfile(
      id: row['id'] as String,
      email: row['email'] as String,
      fullName: row['full_name'] as String?,
      phone: row['phone'] as String?,
      locale: (row['locale'] as String?) ?? 'ar',
    );
  }

  AuthSessionInfo? _mapSession(Session? session) {
    if (session == null) return null;
    final user = session.user;
    return AuthSessionInfo(
      userId: user.id,
      email: user.email ?? '',
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }

  AuthSignal _mapSignal(AuthChangeEvent event) {
    return switch (event) {
      AuthChangeEvent.initialSession => AuthSignal.initialSession,
      AuthChangeEvent.signedIn => AuthSignal.signedIn,
      AuthChangeEvent.signedOut => AuthSignal.signedOut,
      AuthChangeEvent.passwordRecovery => AuthSignal.passwordRecovery,
      AuthChangeEvent.tokenRefreshed => AuthSignal.tokenRefreshed,
      AuthChangeEvent.userUpdated => AuthSignal.userUpdated,
      _ => AuthSignal.unknown,
    };
  }
}
