import 'package:calculff_client/core/config/supabase_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseBuildConfiguration', () {
    test('accepts HTTPS URL and publishable key', () {
      final result = SupabaseBuildConfiguration.validate(
        url: 'https://example.supabase.co',
        publishableKey: 'sb_publishable_public-value',
      );
      expect(result.status, SupabaseConfigurationStatus.valid);
    });

    test('rejects HTTP', () {
      final result = SupabaseBuildConfiguration.validate(
        url: 'http://example.supabase.co',
        publishableKey: 'sb_publishable_public-value',
      );
      expect(result.issue, SupabaseConfigurationIssue.insecureUrl);
    });

    test('rejects service role key', () {
      final result = SupabaseBuildConfiguration.validate(
        url: 'https://example.supabase.co',
        publishableKey: 'service_role_value',
      );
      expect(result.issue, SupabaseConfigurationIssue.invalidPublishableKey);
    });

    test('rejects secret key', () {
      final result = SupabaseBuildConfiguration.validate(
        url: 'https://example.supabase.co',
        publishableKey: 'sb_secret_value',
      );
      expect(result.issue, SupabaseConfigurationIssue.invalidPublishableKey);
    });

    test('rejects surrounding whitespace', () {
      final result = SupabaseBuildConfiguration.validate(
        url: ' https://example.supabase.co',
        publishableKey: 'sb_publishable_public-value',
      );
      expect(result.issue, SupabaseConfigurationIssue.malformedWhitespace);
    });
  });
}
