import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/catalog_failure.dart';
import 'catalog_payload_reader.dart';

abstract final class CatalogErrorMapper {
  static CatalogFailure map(Object error) {
    if (error is CatalogFailure) return error;
    if (error is CatalogPayloadException || error is FormatException) {
      return const CatalogFailure(CatalogFailureType.invalidData);
    }
    if (error is AuthException) {
      return const CatalogFailure(CatalogFailureType.sessionExpired);
    }
    if (error is PostgrestException) {
      final code = error.code?.toUpperCase() ?? '';
      if (code == '42501' ||
          code == '28000' ||
          code == 'PGRST301' ||
          code == 'PGRST302') {
        return const CatalogFailure(CatalogFailureType.sessionExpired);
      }
      return const CatalogFailure(CatalogFailureType.temporary);
    }
    if (error is SocketException ||
        error is TimeoutException ||
        error is HandshakeException) {
      return const CatalogFailure(CatalogFailureType.networkUnavailable);
    }
    return const CatalogFailure(CatalogFailureType.temporary);
  }
}
