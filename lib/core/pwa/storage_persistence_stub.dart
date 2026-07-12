/// Non-web platforms don't need this - Keychain/Keystore-backed storage
/// isn't subject to browser eviction.
Future<bool> requestPersistentStorage() async => true;

Future<void> requestNotificationPermissionForPersistence() async {}
