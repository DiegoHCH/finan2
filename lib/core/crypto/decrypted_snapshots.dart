import 'package:cloud_firestore/cloud_firestore.dart';

extension DecryptedSnapshots on Stream<QuerySnapshot<Map<String, dynamic>>> {
  /// Decodes each snapshot's documents with [decode], decrypting only the
  /// ones that changed since the previous snapshot. A new movement in a year
  /// of hundreds used to decrypt all of them again; now it decrypts one.
  ///
  /// The cache lives as long as the stream: a fresh listen (a provider
  /// rebuilding, say after the household key arrives) starts from scratch.
  Stream<List<T>> decryptEach<T>(
    Future<T> Function(DocumentSnapshot<Map<String, dynamic>> doc) decode,
  ) {
    final cache = <String, T>{};
    return asyncMap((snap) async {
      for (final change in snap.docChanges) {
        if (change.type == DocumentChangeType.removed) cache.remove(change.doc.id);
      }
      await Future.wait([
        for (final change in snap.docChanges)
          if (change.type != DocumentChangeType.removed)
            decode(change.doc).then((value) => cache[change.doc.id] = value),
      ]);
      return [for (final doc in snap.docs) cache[doc.id] ?? await decode(doc)];
    });
  }
}
