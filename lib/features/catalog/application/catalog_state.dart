import '../domain/catalog_failure.dart';

enum CatalogLoadStatus { initial, loading, data, empty, failure }

class CatalogListState<T> {
  const CatalogListState({
    this.status = CatalogLoadStatus.initial,
    this.items = const [],
    this.failure,
    this.isRefreshing = false,
  });

  final CatalogLoadStatus status;
  final List<T> items;
  final CatalogFailure? failure;
  final bool isRefreshing;

  bool get hasItems => items.isNotEmpty;

  CatalogListState<T> copyWith({
    CatalogLoadStatus? status,
    List<T>? items,
    CatalogFailure? failure,
    bool clearFailure = false,
    bool? isRefreshing,
  }) {
    return CatalogListState<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: clearFailure ? null : failure ?? this.failure,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
