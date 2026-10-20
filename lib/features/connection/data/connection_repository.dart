import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/offline_signal.dart';

/// Whether this device is reaching Firestore, read from Firestore itself
/// rather than from the network: while the client can't reach the server,
/// every snapshot it hands out comes from its cache. Watches the household
/// document, which the app already listens to, so it costs no extra reads.
class ConnectionRepository {
  ConnectionRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// True while offline - see [offlineSignal] for the grace on start.
  Stream<bool> watchOffline(String householdId) => offlineSignal(
    _db
        .collection('households')
        .doc(householdId)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.metadata.isFromCache),
  );
}
