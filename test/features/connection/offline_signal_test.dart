import 'dart:async';

import 'package:finan2/features/connection/domain/offline_signal.dart';
import 'package:flutter_test/flutter_test.dart';

const _grace = Duration(milliseconds: 60);

Future<void> _wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  test('a first answer from the cache is not offline yet', () async {
    final fromCache = StreamController<bool>();
    final seen = <bool>[];
    offlineSignal(fromCache.stream, grace: _grace).listen(seen.add);

    fromCache.add(true);
    await _wait(20);
    fromCache.add(false);
    await _wait(120);

    expect(seen, [false]);
  });

  test('only the cache for the whole grace is offline; back at once', () async {
    final fromCache = StreamController<bool>();
    final seen = <bool>[];
    offlineSignal(fromCache.stream, grace: _grace).listen(seen.add);

    fromCache
      ..add(false)
      ..add(true);
    await _wait(20);
    expect(seen, [false]);
    fromCache.add(true);
    await _wait(80);
    expect(seen, [false, true]);

    fromCache.add(false);
    await _wait(1);
    expect(seen, [false, true, false]);
  });
}
