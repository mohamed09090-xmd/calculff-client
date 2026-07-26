import 'dart:async';

import 'package:calculff_client/features/catalog/application/catalog_controller.dart';
import 'package:calculff_client/features/catalog/application/catalog_state.dart';
import 'package:calculff_client/features/catalog/domain/catalog_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('load exposes loading then authenticated catalog data', () async {
    final completer = Completer<List<int>>();
    final controller = CatalogController<int>(
      loader: () => completer.future,
      onSessionExpired: () async {},
    );
    addTearDown(controller.dispose);

    final future = controller.load();
    expect(controller.state.status, CatalogLoadStatus.loading);

    completer.complete([1, 2]);
    await future;
    expect(controller.state.status, CatalogLoadStatus.data);
    expect(controller.state.items, [1, 2]);
  });

  test('empty result exposes the empty state', () async {
    final controller = CatalogController<int>(
      loader: () async => <int>[],
      onSessionExpired: () async {},
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.state.status, CatalogLoadStatus.empty);
    expect(controller.state.items, isEmpty);
  });

  test('error can be retried successfully', () async {
    var calls = 0;
    final controller = CatalogController<int>(
      loader: () async {
        calls++;
        if (calls == 1) {
          throw const CatalogFailure(CatalogFailureType.networkUnavailable);
        }
        return [7];
      },
      onSessionExpired: () async {},
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.status, CatalogLoadStatus.failure);
    expect(
      controller.state.failure?.type,
      CatalogFailureType.networkUnavailable,
    );

    await controller.retry();
    expect(controller.state.status, CatalogLoadStatus.data);
    expect(controller.state.items, [7]);
    expect(calls, 2);
  });

  test('refresh keeps current data until replacement arrives', () async {
    var calls = 0;
    final refreshCompleter = Completer<List<int>>();
    final controller = CatalogController<int>(
      loader: () {
        calls++;
        return calls == 1 ? Future.value([1]) : refreshCompleter.future;
      },
      onSessionExpired: () async {},
    );
    addTearDown(controller.dispose);
    await controller.load();

    final future = controller.refresh();
    expect(controller.state.items, [1]);
    expect(controller.state.isRefreshing, isTrue);

    refreshCompleter.complete([2]);
    await future;
    expect(controller.state.items, [2]);
    expect(controller.state.isRefreshing, isFalse);
  });

  test('repeated requests are ignored while loading', () async {
    var calls = 0;
    final completer = Completer<List<int>>();
    final controller = CatalogController<int>(
      loader: () {
        calls++;
        return completer.future;
      },
      onSessionExpired: () async {},
    );
    addTearDown(controller.dispose);

    final first = controller.load();
    final second = controller.load();
    expect(calls, 1);

    completer.complete([1]);
    await Future.wait([first, second]);
    expect(controller.state.items, [1]);
  });

  test('session expiry invokes the secure sign-out callback', () async {
    var signOutCalls = 0;
    final controller = CatalogController<int>(
      loader: () async {
        throw const CatalogFailure(CatalogFailureType.sessionExpired);
      },
      onSessionExpired: () async {
        signOutCalls++;
      },
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(signOutCalls, 1);
    expect(controller.state.items, isEmpty);
  });
}
