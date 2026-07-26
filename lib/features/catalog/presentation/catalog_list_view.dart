import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/catalog_state.dart';
import '../domain/catalog_failure.dart';

class CatalogListView<T> extends StatelessWidget {
  const CatalogListView({
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.itemBuilder,
    required this.emptyTitle,
    required this.emptyBody,
    required this.semanticsLabel,
    super.key,
  });

  final CatalogListState<T> state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyTitle;
  final String emptyBody;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    if (state.status == CatalogLoadStatus.loading && !state.hasItems) {
      return Semantics(
        label: AppLocalizations.of(context).semanticsLoading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == CatalogLoadStatus.failure && !state.hasItems) {
      return _FullError(failure: state.failure, onRetry: onRetry);
    }

    return Semantics(
      label: semanticsLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!state.hasItems) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  SizedBox(
                    height: (constraints.maxHeight - 48)
                        .clamp(0, double.infinity)
                        .toDouble(),
                    child: _EmptyState(title: emptyTitle, body: emptyBody),
                  ),
                ],
              ),
            );
          }

          final itemCount =
              state.items.length + (state.failure == null ? 0 : 1);
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              key: const PageStorageKey<String>('catalog-list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (state.failure != null && index == 0) {
                  return _InlineError(failure: state.failure, onRetry: onRetry);
                }
                final itemIndex = index - (state.failure == null ? 0 : 1);
                return itemBuilder(context, state.items[itemIndex]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _FullError extends StatelessWidget {
  const _FullError({required this.failure, required this.onRetry});

  final CatalogFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.semanticsError,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  _failureMessage(l10n, failure),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.failure, required this.onRetry});

  final CatalogFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.semanticsError,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded),
              const SizedBox(width: 12),
              Expanded(child: Text(_failureMessage(l10n, failure))),
              TextButton(onPressed: onRetry, child: Text(l10n.retry)),
            ],
          ),
        ),
      ),
    );
  }
}

String _failureMessage(AppLocalizations l10n, CatalogFailure? failure) {
  return switch (failure?.type) {
    CatalogFailureType.networkUnavailable => l10n.catalogNetworkError,
    CatalogFailureType.invalidData => l10n.catalogInvalidData,
    CatalogFailureType.sessionExpired => l10n.catalogSessionExpired,
    CatalogFailureType.temporary || null => l10n.catalogTemporaryError,
  };
}
