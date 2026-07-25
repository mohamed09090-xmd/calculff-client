enum SupabaseConfigurationStatus { valid, missing, invalid }

enum SupabaseConfigurationIssue {
  missingUrl,
  missingPublishableKey,
  malformedWhitespace,
  invalidUrl,
  insecureUrl,
  invalidPublishableKey,
  placeholderValue,
}

class SupabaseConfiguration {
  const SupabaseConfiguration({
    required this.url,
    required this.publishableKey,
  });

  final String url;
  final String publishableKey;
}

class SupabaseConfigurationResult {
  const SupabaseConfigurationResult._({
    required this.status,
    this.configuration,
    this.issue,
  });

  const SupabaseConfigurationResult.valid(SupabaseConfiguration value)
    : this._(status: SupabaseConfigurationStatus.valid, configuration: value);

  const SupabaseConfigurationResult.missing(SupabaseConfigurationIssue issue)
    : this._(status: SupabaseConfigurationStatus.missing, issue: issue);

  const SupabaseConfigurationResult.invalid(SupabaseConfigurationIssue issue)
    : this._(status: SupabaseConfigurationStatus.invalid, issue: issue);

  final SupabaseConfigurationStatus status;
  final SupabaseConfiguration? configuration;
  final SupabaseConfigurationIssue? issue;
}

abstract final class SupabaseBuildConfiguration {
  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static SupabaseConfigurationResult get current =>
      validate(url: _url, publishableKey: _publishableKey);

  static SupabaseConfigurationResult validate({
    required String url,
    required String publishableKey,
  }) {
    if (url.isEmpty) {
      return const SupabaseConfigurationResult.missing(
        SupabaseConfigurationIssue.missingUrl,
      );
    }
    if (publishableKey.isEmpty) {
      return const SupabaseConfigurationResult.missing(
        SupabaseConfigurationIssue.missingPublishableKey,
      );
    }
    if (url != url.trim() || publishableKey != publishableKey.trim()) {
      return const SupabaseConfigurationResult.invalid(
        SupabaseConfigurationIssue.malformedWhitespace,
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
      return const SupabaseConfigurationResult.invalid(
        SupabaseConfigurationIssue.invalidUrl,
      );
    }
    if (uri.scheme.toLowerCase() != 'https') {
      return const SupabaseConfigurationResult.invalid(
        SupabaseConfigurationIssue.insecureUrl,
      );
    }
    if (uri.userInfo.isNotEmpty ||
        (uri.hasPort && uri.port != 443) ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      return const SupabaseConfigurationResult.invalid(
        SupabaseConfigurationIssue.invalidUrl,
      );
    }

    final lowerKey = publishableKey.toLowerCase();
    if (lowerKey.startsWith('sb_secret_') ||
        lowerKey.contains('service_role') ||
        lowerKey.contains('service-role')) {
      return const SupabaseConfigurationResult.invalid(
        SupabaseConfigurationIssue.invalidPublishableKey,
      );
    }
    if (lowerKey.contains('placeholder') ||
        lowerKey.contains('replace_me') ||
        lowerKey.contains('replace-me') ||
        lowerKey == 'your_publishable_key' ||
        lowerKey == 'changeme') {
      return const SupabaseConfigurationResult.invalid(
        SupabaseConfigurationIssue.placeholderValue,
      );
    }

    return SupabaseConfigurationResult.valid(
      SupabaseConfiguration(
        url: uri.replace(path: '').toString(),
        publishableKey: publishableKey,
      ),
    );
  }
}
