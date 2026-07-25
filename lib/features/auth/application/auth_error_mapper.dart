import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_models.dart';

abstract final class AuthErrorMapper {
  static AuthFailure map(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return const AuthFailure(AuthFailureType.networkUnavailable);
    }
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid login') ||
          message.contains('invalid credentials') ||
          message.contains('email or password')) {
        return const AuthFailure(AuthFailureType.invalidCredentials);
      }
      if (message.contains('email not confirmed') ||
          message.contains('email_not_confirmed')) {
        return const AuthFailure(AuthFailureType.emailNotConfirmed);
      }
      if (message.contains('rate') ||
          message.contains('too many') ||
          message.contains('over_email_send_rate_limit')) {
        return const AuthFailure(AuthFailureType.tooManyRequests);
      }
      if (message.contains('network') || message.contains('socket')) {
        return const AuthFailure(AuthFailureType.networkUnavailable);
      }
    }
    return const AuthFailure(AuthFailureType.temporary);
  }
}
