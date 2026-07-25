enum ValidationIssue {
  invalidEmail,
  requiredName,
  invalidName,
  invalidPhone,
  shortPassword,
  passwordWhitespace,
  passwordsDoNotMatch,
}

abstract final class AuthValidators {
  static final _emailPattern = RegExp(
    r'^[A-Za-z0-9.!#$%&\'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
  );
  static final _phonePattern = RegExp(r'^[0-9+(). -]+$');

  static ValidationIssue? email(String value) {
    final normalized = value.trim();
    if (normalized.length > 320 || !_emailPattern.hasMatch(normalized)) {
      return ValidationIssue.invalidEmail;
    }
    return null;
  }

  static ValidationIssue? name(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return ValidationIssue.requiredName;
    if (normalized.length < 2 || normalized.length > 100) {
      return ValidationIssue.invalidName;
    }
    return null;
  }

  static ValidationIssue? phone(String value) {
    final normalized = value.trim();
    final digitCount = normalized.replaceAll(RegExp('[^0-9]'), '').length;
    if (normalized.length < 6 ||
        normalized.length > 25 ||
        digitCount < 6 ||
        digitCount > 15 ||
        !_phonePattern.hasMatch(normalized)) {
      return ValidationIssue.invalidPhone;
    }
    return null;
  }

  static ValidationIssue? password(String value) {
    if (value.length < 8) return ValidationIssue.shortPassword;
    if (value != value.trim()) return ValidationIssue.passwordWhitespace;
    return null;
  }

  static ValidationIssue? confirmation(String password, String confirmation) {
    if (password != confirmation) return ValidationIssue.passwordsDoNotMatch;
    return null;
  }
}
