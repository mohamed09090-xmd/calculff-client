import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/route_decision.dart';
import '../../../core/widgets/client_page_frame.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../application/auth_providers.dart';
import '../domain/auth_models.dart';
import '../domain/auth_validators.dart';

String authFailureMessage(AppLocalizations l10n, AuthFailure? failure) {
  return switch (failure?.type) {
    AuthFailureType.invalidCredentials => l10n.invalidCredentials,
    AuthFailureType.emailNotConfirmed => l10n.emailNotConfirmed,
    AuthFailureType.networkUnavailable => l10n.networkUnavailable,
    AuthFailureType.tooManyRequests => l10n.tooManyRequests,
    AuthFailureType.invalidConfiguration => l10n.invalidConfiguration,
    AuthFailureType.temporary || null => l10n.temporaryError,
  };
}

String validationMessage(AppLocalizations l10n, ValidationIssue issue) {
  return switch (issue) {
    ValidationIssue.invalidEmail => l10n.invalidEmail,
    ValidationIssue.requiredName => l10n.requiredName,
    ValidationIssue.invalidName => l10n.invalidName,
    ValidationIssue.invalidPhone => l10n.invalidPhone,
    ValidationIssue.shortPassword => l10n.shortPassword,
    ValidationIssue.passwordWhitespace => l10n.passwordWhitespace,
    ValidationIssue.passwordsDoNotMatch => l10n.passwordsDoNotMatch,
  };
}

class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Semantics(
            label: l10n.semanticsLoading,
            liveRegion: true,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClientPageFrame(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.link_off_rounded,
              size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 28),
          Text(
            l10n.setupTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(l10n.setupBody, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          SelectableText(l10n.setupHint, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class BootstrapErrorScreen extends ConsumerWidget {
  const BootstrapErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    return ClientPageFrame(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.shield_outlined, size: 56),
          const SizedBox(height: 24),
          Text(l10n.bootstrapErrorTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            state.failure?.type == AuthFailureType.invalidConfiguration
                ? l10n.invalidConfiguration
                : l10n.bootstrapErrorBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: state.isBusy
                ? null
                : ref.read(authControllerProvider.notifier).retryInitialization,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    return ClientPageFrame(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text('CalculFF Client'),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(l10n.welcomeTitle,
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 18),
          Text(l10n.welcomeBody,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 42),
          ElevatedButton(
            onPressed: () => context.go(AppPaths.login),
            child: Text(l10n.signIn),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go(AppPaths.signup),
            child: Text(l10n.createAccount),
          ),
          const SizedBox(height: 24),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
              ButtonSegment(value: 'fr', label: Text(l10n.french)),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (value) {
              ref.read(localeControllerProvider.notifier).setLocale(value.first);
            },
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    return ClientPageFrame(
      title: l10n.signIn,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Semantics(
              label: l10n.semanticsEmailField,
              textField: true,
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l10n.email),
                validator: (value) {
                  final issue = AuthValidators.email(value ?? '');
                  return issue == null ? null : validationMessage(l10n, issue);
                },
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: l10n.semanticsPasswordField,
              textField: true,
              child: TextFormField(
                controller: _password,
                obscureText: _obscure,
                textDirection: TextDirection.ltr,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: l10n.password,
                  suffixIcon: IconButton(
                    tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (value) {
                  final issue = AuthValidators.password(value ?? '');
                  return issue == null ? null : validationMessage(l10n, issue);
                },
              ),
            ),
            if (state.failure != null) ...[
              const SizedBox(height: 16),
              _InlineError(message: authFailureMessage(l10n, state.failure)),
            ],
            const SizedBox(height: 24),
            Semantics(
              label: l10n.semanticsSubmit,
              button: true,
              child: ElevatedButton(
                onPressed: state.isBusy
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          ref.read(authControllerProvider.notifier).signIn(
                                _email.text,
                                _password.text,
                              );
                        }
                      },
                child: state.isBusy
                    ? const _ButtonProgress()
                    : Text(l10n.signIn),
              ),
            ),
            TextButton(
              onPressed: state.isBusy
                  ? null
                  : () => context.go(AppPaths.forgotPassword),
              child: Text(l10n.forgotPassword),
            ),
            TextButton(
              onPressed:
                  state.isBusy ? null : () => context.go(AppPaths.signup),
              child: Text('${l10n.noAccount} ${l10n.createAccount}'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    return ClientPageFrame(
      title: l10n.createAccount,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.fullName),
              validator: (value) {
                final issue = AuthValidators.name(value ?? '');
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.phone),
              validator: (value) {
                final issue = AuthValidators.phone(value ?? '');
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.newUsername],
              decoration: InputDecoration(labelText: l10n.email),
              validator: (value) {
                final issue = AuthValidators.email(value ?? '');
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: l10n.password,
                suffixIcon: IconButton(
                  tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) {
                final issue = AuthValidators.password(value ?? '');
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmation,
              obscureText: _obscure,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.confirmPassword),
              validator: (value) {
                final issue = AuthValidators.confirmation(
                  _password.text,
                  value ?? '',
                );
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: locale.languageCode,
              decoration: InputDecoration(labelText: l10n.language),
              items: [
                DropdownMenuItem(value: 'ar', child: Text(l10n.arabic)),
                DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
              ],
              onChanged: state.isBusy
                  ? null
                  : (value) {
                      if (value != null) {
                        ref
                            .read(localeControllerProvider.notifier)
                            .setLocale(value);
                      }
                    },
            ),
            if (state.failure != null) ...[
              const SizedBox(height: 16),
              _InlineError(message: authFailureMessage(l10n, state.failure)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isBusy
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref.read(authControllerProvider.notifier).signUp(
                              fullName: _name.text,
                              phone: _phone.text,
                              email: _email.text,
                              password: _password.text,
                              locale: ref
                                  .read(localeControllerProvider)
                                  .languageCode,
                            );
                      }
                    },
              child: state.isBusy
                  ? const _ButtonProgress()
                  : Text(l10n.createAccount),
            ),
            TextButton(
              onPressed:
                  state.isBusy ? null : () => context.go(AppPaths.login),
              child: Text('${l10n.alreadyHaveAccount} ${l10n.signIn}'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final email = state.email ?? '';
    return ClientPageFrame(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.mark_email_unread_outlined, size: 64),
          const SizedBox(height: 24),
          Text(l10n.verifyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 14),
          Text(l10n.verifyBody(_maskEmail(email)), textAlign: TextAlign.center),
          if (state.failure != null) ...[
            const SizedBox(height: 16),
            _InlineError(message: authFailureMessage(l10n, state.failure)),
          ],
          const SizedBox(height: 26),
          ElevatedButton(
            onPressed: state.isBusy
                ? null
                : ref.read(authControllerProvider.notifier).checkVerification,
            child: state.isBusy
                ? const _ButtonProgress()
                : Text(l10n.checkVerification),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: state.isBusy || state.resendCooldownSeconds > 0
                ? null
                : ref
                    .read(authControllerProvider.notifier)
                    .resendConfirmation,
            child: Text(
              state.resendCooldownSeconds > 0
                  ? l10n.resendCooldown(state.resendCooldownSeconds)
                  : l10n.resendConfirmation,
            ),
          ),
          TextButton(
            onPressed: state.isBusy
                ? null
                : ref.read(authControllerProvider.notifier).signOut,
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    return ClientPageFrame(
      title: l10n.forgotTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.forgotBody),
            const SizedBox(height: 22),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.email),
              validator: (value) {
                final issue = AuthValidators.email(value ?? '');
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            if (state.recoveryRequestSent) ...[
              const SizedBox(height: 18),
              Semantics(
                liveRegion: true,
                child: Text(l10n.resetRequestSuccess),
              ),
            ],
            if (state.failure != null) ...[
              const SizedBox(height: 16),
              _InlineError(message: authFailureMessage(l10n, state.failure)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isBusy
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref
                            .read(authControllerProvider.notifier)
                            .requestPasswordReset(_email.text);
                      }
                    },
              child: state.isBusy
                  ? const _ButtonProgress()
                  : Text(l10n.continueAction),
            ),
            TextButton(
              onPressed:
                  state.isBusy ? null : () => context.go(AppPaths.login),
              child: Text(l10n.back),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    return ClientPageFrame(
      title: l10n.resetTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: l10n.newPassword,
                suffixIcon: IconButton(
                  tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) {
                final issue = AuthValidators.password(value ?? '');
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmation,
              obscureText: _obscure,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.confirmPassword),
              validator: (value) {
                final issue = AuthValidators.confirmation(
                  _password.text,
                  value ?? '',
                );
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            if (state.failure != null) ...[
              const SizedBox(height: 16),
              _InlineError(message: authFailureMessage(l10n, state.failure)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isBusy
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref
                            .read(authControllerProvider.notifier)
                            .updatePassword(_password.text);
                      }
                    },
              child: state.isBusy
                  ? const _ButtonProgress()
                  : Text(l10n.savePassword),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: AppLocalizations.of(context).semanticsError,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.error),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: scheme.error),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ButtonProgress extends StatelessWidget {
  const _ButtonProgress();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
}

String _maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2 || parts.first.isEmpty) return email;
  final local = parts.first;
  final visible = local.length <= 2 ? local.substring(0, 1) : local.substring(0, 2);
  return '$visible•••@${parts.last}';
}
