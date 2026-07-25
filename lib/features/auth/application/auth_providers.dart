import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/runtime/client_runtime_bootstrap.dart';
import 'auth_controller.dart';
import '../domain/auth_models.dart';

final runtimeBootstrapProvider = Provider<ClientRuntimeBootstrap>((ref) {
  return SupabaseClientRuntimeBootstrap();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final controller = AuthController(
      runtimeBootstrap: ref.watch(runtimeBootstrapProvider),
    );
    Future.microtask(controller.initialize);
    return controller;
  },
);
