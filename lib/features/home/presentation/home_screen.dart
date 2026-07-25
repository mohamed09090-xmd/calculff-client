import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/route_decision.dart';
import '../../../core/widgets/client_page_frame.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../../settings/application/settings_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final name = auth.profile?.displayName ?? auth.session?.email ?? '';
    return ClientPageFrame(
      title: l10n.homeTitle,
      actions: [
        IconButton(
          tooltip: l10n.profile,
          onPressed: () => context.go(AppPaths.profile),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.helloUser(name),
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified_outlined),
              const SizedBox(width: 8),
              Text(l10n.accountConfirmed),
            ],
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.layers_outlined, size: 44),
                const SizedBox(height: 14),
                Text(l10n.catalogNextPhase, textAlign: TextAlign.center),
              ],
            ),
          ),
          const Spacer(),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
              ButtonSegment(value: 'fr', label: Text(l10n.french)),
            ],
            selected: {ref.watch(localeControllerProvider).languageCode},
            onSelectionChanged: (value) {
              ref.read(localeControllerProvider.notifier).setLocale(value.first);
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: auth.isBusy
                ? null
                : ref.read(authControllerProvider.notifier).signOut,
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
