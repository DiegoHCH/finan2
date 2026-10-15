import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/decrypted_snapshots.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes only the documents that changed', () async {
    final firestore = FakeFirebaseFirestore();
    final col = firestore.collection('items');
    await col.doc('a').set({'v': 1});
    await col.doc('b').set({'v': 2});

    final decoded = <String>[];
    final lists = <List<int>>[];
    final sub = col
        .orderBy('v')
        .snapshots()
        .decryptEach((doc) async {
          decoded.add(doc.id);
          return doc.data()!['v'] as int;
        })
        .listen(lists.add);

    await pumpEventQueue();
    expect(lists.last, [1, 2]);
    expect(decoded, unorderedEquals(['a', 'b']));

    decoded.clear();
    await col.doc('c').set({'v': 3});
    await pumpEventQueue();
    expect(lists.last, [1, 2, 3]);
    expect(decoded, ['c']);

    decoded.clear();
    await col.doc('a').update({'v': 4});
    await col.doc('b').delete();
    await pumpEventQueue();
    expect(lists.last, [3, 4]);
    expect(decoded, ['a']);

    await sub.cancel();
  });
}
