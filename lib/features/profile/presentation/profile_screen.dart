import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/route_decision.dart';
import '../../../core/widgets/client_page_frame.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_validators.dart';
import '../../auth/presentation/auth_screens.dart';
import '../../settings/application/settings_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late String _locale;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authControllerProvider).profile;
    _name = TextEditingController(text: profile?.fullName ?? '');
    _phone = TextEditingController(text: profile?.phone ?? '');
    _locale =
        profile?.locale ?? ref.read(localeControllerProvider).languageCode;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final session = auth.session;
    return ClientPageFrame(
      title: l10n.profileTitle,
      actions: [
        IconButton(
          tooltip: l10n.homeTitle,
          onPressed: () => context.go(AppPaths.home),
          icon: const Icon(Icons.home_outlined),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: session?.email ?? auth.profile?.email ?? '',
              readOnly: true,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.email),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  session?.emailConfirmed == true
                      ? Icons.verified_outlined
                      : Icons.warning_amber_outlined,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session?.emailConfirmed == true
                        ? l10n.emailConfirmed
                        : l10n.emailUnconfirmed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _name,
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
              decoration: InputDecoration(labelText: l10n.phone),
              validator: (value) {
                final issue = AuthValidators.phone(value ?? '');
                return issue == null ? null : validationMessage(l10n, issue);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _locale,
              decoration: InputDecoration(labelText: l10n.language),
              items: [
                DropdownMenuItem(value: 'ar', child: Text(l10n.arabic)),
                DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
              ],
              onChanged: auth.isBusy
                  ? null
                  : (value) {
                      if (value != null) setState(() => _locale = value);
                    },
            ),
            const SizedBox(height: 20),
            Text(l10n.theme, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<ThemeMode>(
              initialValue: ref.watch(themeModeControllerProvider),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.lightTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.darkTheme),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeControllerProvider.notifier).setMode(value);
                }
              },
            ),
            if (auth.failure != null) ...[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(authFailureMessage(l10n, auth.failure)),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: auth.isBusy
                  ? null
                  : () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(_locale);
                      await ref
                          .read(authControllerProvider.notifier)
                          .updateProfile(
                            fullName: _name.text,
                            phone: _phone.text,
                            locale: _locale,
                          );
                    },
              child: auth.isBusy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }
}
