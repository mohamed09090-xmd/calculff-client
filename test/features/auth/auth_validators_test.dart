import 'package:calculff_client/features/auth/domain/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators', () {
    test('validates email', () {
      expect(AuthValidators.email('client@example.com'), isNull);
      expect(
        AuthValidators.email('invalid'),
        ValidationIssue.invalidEmail,
      );
    });

    test('validates trimmed name length', () {
      expect(AuthValidators.name(' Mohamed '), isNull);
      expect(AuthValidators.name(' '), ValidationIssue.requiredName);
      expect(AuthValidators.name('A'), ValidationIssue.invalidName);
    });

    test('validates phone supported by backend contract', () {
      expect(AuthValidators.phone('+213 555 123 456'), isNull);
      expect(AuthValidators.phone('abc'), ValidationIssue.invalidPhone);
    });

    test('validates password and confirmation', () {
      expect(AuthValidators.password('12345678'), isNull);
      expect(AuthValidators.password('1234567'), ValidationIssue.shortPassword);
      expect(
        AuthValidators.password(' 12345678'),
        ValidationIssue.passwordWhitespace,
      );
      expect(
        AuthValidators.confirmation('12345678', '87654321'),
        ValidationIssue.passwordsDoNotMatch,
      );
    });
  });
}
