import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/catalog_failure.dart';
import 'catalog_state.dart';

typedef CatalogLoader<T> = Future<List<T>> Function();
typedef SessionExpiredHandler = Future<void> Function();

class CatalogController<T> extends StateNotifier<CatalogListState<T>> {
  CatalogController({
    required CatalogLoader<T> loader,
    required SessionExpiredHandler onSessionExpired,
  }) : _loader = loader,
       _onSessionExpired = onSessionExpired,
       super(CatalogListState<T>());

  final CatalogLoader<T> _loader;
  final SessionExpiredHandler _onSessionExpired;
  bool _requestInFlight = false;

  Future<void> load() => _run(refresh: false);

  Future<void> retry() => _run(refresh: false);

  Future<void> refresh() => _run(refresh: true);

  Future<void> _run({required bool refresh}) async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    if (refresh && state.hasItems) {
      state = state.copyWith(isRefreshing: true, clearFailure: true);
    } else {
      state = state.copyWith(
        status: CatalogLoadStatus.loading,
        isRefreshing: false,
        clearFailure: true,
      );
    }

    try {
      final items = await _loader();
      if (!mounted) return;
      state = CatalogListState<T>(
        status: items.isEmpty
            ? CatalogLoadStatus.empty
            : CatalogLoadStatus.data,
        items: List<T>.unmodifiable(items),
      );
    } on CatalogFailure catch (failure) {
      if (!mounted) return;
      if (failure.type == CatalogFailureType.sessionExpired) {
        await _onSessionExpired();
        return;
      }
      state = CatalogListState<T>(
        status: state.hasItems
            ? CatalogLoadStatus.data
            : CatalogLoadStatus.failure,
        items: state.items,
        failure: failure,
      );
    } catch (_) {
      if (!mounted) return;
      state = CatalogListState<T>(
        status: state.hasItems
            ? CatalogLoadStatus.data
            : CatalogLoadStatus.failure,
        items: state.items,
        failure: const CatalogFailure(CatalogFailureType.temporary),
      );
    } finally {
      _requestInFlight = false;
      if (mounted && state.isRefreshing) {
        state = state.copyWith(isRefreshing: false);
      }
    }
  }
}
