import 'dart:convert';

import '../../../core/security/secure_supabase_local_storage.dart';
import '../domain/auth_models.dart';

class PendingProfileStore {
  const PendingProfileStore(this._store);

  static const _key = 'calculff_client.pending_profile.v1';
  final SecureValueStore _store;

  Future<void> save(PendingProfile profile) {
    return _store.write(
      _key,
      jsonEncode({
        'full_name': profile.fullName,
        'phone': profile.phone,
        'locale': profile.locale,
      }),
    );
  }

  Future<PendingProfile?> read() async {
    final value = await _store.read(_key);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) return null;
      final fullName = decoded['full_name'];
      final phone = decoded['phone'];
      final locale = decoded['locale'];
      if (fullName is! String || phone is! String || locale is! String) {
        return null;
      }
      return PendingProfile(
        fullName: fullName,
        phone: phone,
        locale: locale,
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> clear() => _store.delete(_key);
}
