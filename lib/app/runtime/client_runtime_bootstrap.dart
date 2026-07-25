import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_configuration.dart';
import '../../core/security/secure_supabase_local_storage.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/infrastructure/pending_profile_store.dart';
import '../../features/auth/infrastructure/supabase_auth_repository.dart';

enum RuntimeBootstrapStatus {
  available,
  configMissing,
  invalidConfiguration,
  failed,
}

class RuntimeBootstrapResult {
  const RuntimeBootstrapResult._({required this.status, this.repository});

  const RuntimeBootstrapResult.available(AuthRepository repository)
      : this._(
          status: RuntimeBootstrapStatus.available,
          repository: repository,
        );
  const RuntimeBootstrapResult.configMissing()
      : this._(status: RuntimeBootstrapStatus.configMissing);
  const RuntimeBootstrapResult.invalidConfiguration()
      : this._(status: RuntimeBootstrapStatus.invalidConfiguration);
  const RuntimeBootstrapResult.failed()
      : this._(status: RuntimeBootstrapStatus.failed);

  final RuntimeBootstrapStatus status;
  final AuthRepository? repository;
}

abstract interface class ClientRuntimeBootstrap {
  Future<RuntimeBootstrapResult> initialize();
}

class SupabaseClientRuntimeBootstrap implements ClientRuntimeBootstrap {
  SupabaseClientRuntimeBootstrap({
    SupabaseConfigurationResult? configurationResult,
    SecureStorageBackend? secureStorage,
  })  : _configurationResult =
            configurationResult ?? SupabaseBuildConfiguration.current,
        _secureStorage = secureStorage ?? const FlutterSecureStorageBackend();

  final SupabaseConfigurationResult _configurationResult;
  final SecureStorageBackend _secureStorage;

  @override
  Future<RuntimeBootstrapResult> initialize() async {
    switch (_configurationResult.status) {
      case SupabaseConfigurationStatus.missing:
        return const RuntimeBootstrapResult.configMissing();
      case SupabaseConfigurationStatus.invalid:
        return const RuntimeBootstrapResult.invalidConfiguration();
      case SupabaseConfigurationStatus.valid:
        break;
    }
    final configuration = _configurationResult.configuration;
    if (configuration == null) {
      return const RuntimeBootstrapResult.invalidConfiguration();
    }

    try {
      final localStorage = SecureSupabaseLocalStorage(storage: _secureStorage);
      final supabase = await Supabase.initialize(
        url: configuration.url,
        publishableKey: configuration.publishableKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: localStorage,
          detectSessionInUri: true,
        ),
        debug: false,
      );
      final pendingStore = PendingProfileStore(SecureValueStore(_secureStorage));
      return RuntimeBootstrapResult.available(
        SupabaseAuthRepository(
          client: supabase.client,
          localStorage: localStorage,
          pendingProfileStore: pendingStore,
        ),
      );
    } catch (_) {
      return const RuntimeBootstrapResult.failed();
    }
  }
}
