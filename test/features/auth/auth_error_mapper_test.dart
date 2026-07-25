import 'dart:io';

import 'package:calculff_client/features/auth/application/auth_error_mapper.dart';
import 'package:calculff_client/features/auth/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('maps invalid credentials without exposing raw error', () {
    final failure = AuthErrorMapper.map(
      const AuthException('Invalid login credentials'),
    );
    expect(failure.type, AuthFailureType.invalidCredentials);
  });

  test('maps unconfirmed email', () {
    final failure = AuthErrorMapper.map(
      const AuthException('Email not confirmed'),
    );
    expect(failure.type, AuthFailureType.emailNotConfirmed);
  });

  test('maps connection errors', () {
    final failure = AuthErrorMapper.map(const SocketException('offline'));
    expect(failure.type, AuthFailureType.networkUnavailable);
  });
}
