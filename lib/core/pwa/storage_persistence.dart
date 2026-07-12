// Asks the browser to protect this origin's local storage from automatic
// eviction - iOS Safari can otherwise wipe a PWA's storage (and with it,
// HouseholdCrypto's on-device encryption key) if it isn't opened for about
// a week. No-op on native platforms, which don't have this problem.
export 'storage_persistence_stub.dart'
    if (dart.library.js_interop) 'storage_persistence_web.dart';
