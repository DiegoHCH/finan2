import 'dart:async';

/// Turns «is what we're seeing only from this device's cache?» into «are we
/// offline?». Right after a listen starts the first answer usually comes
/// from the cache while the server catches up, so offline is only declared
/// after [grace] of nothing but cache; the way back is immediate. Repeats
/// are dropped, and nothing is said until there's an answer.
Stream<bool> offlineSignal(Stream<bool> fromCache, {Duration grace = const Duration(seconds: 3)}) {
  late final StreamController<bool> controller;
  StreamSubscription<bool>? subscription;
  Timer? timer;
  bool? last;

  void emit(bool offline) {
    if (offline == last) return;
    last = offline;
    controller.add(offline);
  }

  controller = StreamController<bool>(
    onListen: () {
      subscription = fromCache.listen(
        (cached) {
          if (cached) {
            timer ??= Timer(grace, () => emit(true));
          } else {
            timer?.cancel();
            timer = null;
            emit(false);
          }
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          controller.close();
        },
      );
    },
    onCancel: () {
      timer?.cancel();
      return subscription?.cancel();
    },
  );
  return controller.stream;
}
