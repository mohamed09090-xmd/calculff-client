enum CatalogPayloadFailureReason { missing, wrongType, invalidValue }

class CatalogPayloadException implements Exception {
  const CatalogPayloadException({required this.field, required this.reason});

  final String field;
  final CatalogPayloadFailureReason reason;
}

class CatalogPayloadReader {
  const CatalogPayloadReader(this.payload);

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-'
    r'[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  final Map<String, Object?> payload;

  String requiredString(String field, {int maxLength = 120}) {
    final value = _required(field);
    if (value is! String) {
      throw CatalogPayloadException(
        field: field,
        reason: CatalogPayloadFailureReason.wrongType,
      );
    }
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > maxLength) {
      throw CatalogPayloadException(
        field: field,
        reason: CatalogPayloadFailureReason.invalidValue,
      );
    }
    return normalized;
  }

  String requiredUuid(String field) {
    final value = requiredString(field, maxLength: 36);
    if (!_uuidPattern.hasMatch(value)) {
      throw CatalogPayloadException(
        field: field,
        reason: CatalogPayloadFailureReason.invalidValue,
      );
    }
    return value.toLowerCase();
  }

  bool requiredBool(String field) {
    final value = _required(field);
    if (value is! bool) {
      throw CatalogPayloadException(
        field: field,
        reason: CatalogPayloadFailureReason.wrongType,
      );
    }
    return value;
  }

  int requiredInt(String field, {int? minimum}) {
    final value = _required(field);
    if (value is! int) {
      throw CatalogPayloadException(
        field: field,
        reason: CatalogPayloadFailureReason.wrongType,
      );
    }
    if (minimum != null && value < minimum) {
      throw CatalogPayloadException(
        field: field,
        reason: CatalogPayloadFailureReason.invalidValue,
      );
    }
    return value;
  }

  Object _required(String field) {
    if (!payload.containsKey(field) || payload[field] == null) {
      throw CatalogPayloadException(
        field: field,
        reason: CatalogPayloadFailureReason.missing,
      );
    }
    return payload[field]!;
  }
}
