import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/household_crypto.dart';

/// What a backup holds: the household's own data. Push tokens, member
/// preferences, the in-app inbox, alert flags and Worker markers are left
/// out - they belong to devices or get recomputed.
const backupCollections = [
  'accounts',
  'budgets',
  'cardPayments',
  'categories',
  'debts',
  'investments',
  'monthlyNotes',
  'recurringBills',
  'recurringDone',
  'savingsChallenges',
  'savingsGoals',
  'transactions',
  'transfers',
];

/// Whose records firestore.rules attributes with `createdBy` - a member can
/// only create these under their own name.
const _attributedCollections = {
  'accounts',
  'cardPayments',
  'categories',
  'debts',
  'investments',
  'recurringBills',
  'savingsChallenges',
  'savingsGoals',
  'transactions',
  'transfers',
};

const _format = 'finan2-backup';
const _version = 1;
const _sealContext = 'finan2-backup-v1';

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The readable outside of a backup file, checked before decrypting.
class BackupInfo {
  const BackupInfo({required this.householdId, required this.createdAt});

  final String householdId;
  final DateTime createdAt;
}

class RestoreResult {
  const RestoreResult({required this.restored, required this.removed, required this.reattributed});

  /// Documents written back.
  final int restored;

  /// Documents created after the backup, deleted.
  final int removed;

  /// The partner's records that had been deleted since: the rules only let
  /// a member create records under their own name, so they come back as
  /// this member's (movements keep who paid).
  final int reattributed;
}

/// A copy of the whole household, sealed with its key: the file is useless
/// without the key, and the key never leaves the members' devices. The
/// documents are kept as stored, so amounts stay as they are - encrypted
/// with that same key - and balances match the movements at that moment.
class BackupRepository {
  BackupRepository({FirebaseFirestore? firestore, HouseholdCrypto? crypto})
      : _db = firestore ?? FirebaseFirestore.instance,
        _crypto = crypto ?? HouseholdCrypto();

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;

  DocumentReference<Map<String, dynamic>> _household(String id) =>
      _db.collection('households').doc(id);

  Future<List<int>> create(String householdId, {DateTime? now}) async {
    final collections = <String, Map<String, Object?>>{};
    for (final name in backupCollections) {
      final snap = await _household(householdId).collection(name).get();
      collections[name] = {for (final doc in snap.docs) doc.id: _encode(doc.data())};
    }
    final clear = utf8.encode(jsonEncode({'collections': collections}));
    final sealed = await _crypto.seal(householdId, _sealContext, clear);
    return utf8.encode(jsonEncode({
      'format': _format,
      'version': _version,
      'householdId': householdId,
      'createdAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'data': base64Url.encode(sealed),
    }));
  }

  /// Reads the file's outside without the key - to say whose it is.
  BackupInfo inspect(List<int> file) {
    final outer = _outer(file);
    return BackupInfo(
      householdId: outer['householdId'] as String,
      createdAt: DateTime.parse(outer['createdAt'] as String).toLocal(),
    );
  }

  /// Puts the household back as it was in [file]: everything in the backup
  /// is written back and anything created since is deleted. Not atomic -
  /// Firestore can't commit this many writes at once - but running it again
  /// finishes the job.
  Future<RestoreResult> restore(
    String householdId,
    List<int> file, {
    required String currentUid,
  }) async {
    final outer = _outer(file);
    if (outer['householdId'] != householdId) {
      throw const BackupException(
        'Esta copia es de otro hogar. Solo se puede restaurar en el hogar donde se hizo.',
      );
    }
    final List<int> clear;
    try {
      clear = await _crypto.open(
        householdId,
        _sealContext,
        base64Url.decode(outer['data'] as String),
      );
    } on Finan2CryptoException {
      rethrow;
    } catch (_) {
      throw const BackupException('La copia está dañada o se modificó. No se puede abrir.');
    }
    final collections =
        (jsonDecode(utf8.decode(clear)) as Map<String, dynamic>)['collections'] as Map<String, dynamic>;

    var restored = 0;
    var removed = 0;
    var reattributed = 0;
    final writes = _BatchedWrites(_db);

    for (final name in backupCollections) {
      final saved = (collections[name] as Map<String, dynamic>? ?? const {})
          .map((id, data) => MapEntry(id, _decode(data) as Map<String, dynamic>));
      final col = _household(householdId).collection(name);
      final current = {for (final doc in (await col.get()).docs) doc.id: doc.data()};

      for (final id in current.keys) {
        if (saved.containsKey(id)) continue;
        await writes.delete(col.doc(id));
        removed++;
      }
      for (final MapEntry(key: id, value: data) in saved.entries) {
        final exists = current.containsKey(id);
        if (name == 'recurringDone') {
          // Create-only markers: one already there is the same marker.
          if (exists) continue;
          await writes.set(col.doc(id), {'doneAt': data['doneAt']});
          restored++;
          continue;
        }
        var doc = data;
        final createdBy = data['createdBy'];
        if (_attributedCollections.contains(name) &&
            !exists &&
            createdBy is String &&
            createdBy != currentUid) {
          doc = {
            ...data,
            'createdBy': currentUid,
            if (name == 'transactions')
              'paidBy': (data['paidBy'] as String?)?.isNotEmpty ?? false ? data['paidBy'] : createdBy,
          };
          reattributed++;
        }
        await writes.set(col.doc(id), doc);
        restored++;
      }
    }
    await writes.flush();
    return RestoreResult(restored: restored, removed: removed, reattributed: reattributed);
  }

  Map<String, dynamic> _outer(List<int> file) {
    try {
      final outer = jsonDecode(utf8.decode(file)) as Map<String, dynamic>;
      if (outer['format'] == _format &&
          outer['householdId'] is String &&
          outer['createdAt'] is String &&
          outer['data'] is String) {
        if ((outer['version'] as num? ?? 0) > _version) {
          throw const BackupException(
            'Esta copia se hizo con una versión más nueva de Finan2. Actualiza la app.',
          );
        }
        return outer;
      }
    } on BackupException {
      rethrow;
    } catch (_) {
      // Falls through to the generic message.
    }
    throw const BackupException('Este archivo no es una copia de seguridad de Finan2.');
  }
}

/// Firestore values to JSON: timestamps are the only non-JSON type the app
/// stores.
Object? _encode(Object? value) => switch (value) {
      Timestamp t => {r'$ts': t.microsecondsSinceEpoch},
      Map<Object?, Object?> m => {for (final e in m.entries) e.key as String: _encode(e.value)},
      List<Object?> l => [for (final v in l) _encode(v)],
      String() || num() || bool() || null => value,
      _ => throw BackupException('Tipo de dato no soportado en la copia: ${value.runtimeType}'),
    };

Object? _decode(Object? value) => switch (value) {
      {r'$ts': final int micros} when (value as Map).length == 1 =>
        Timestamp.fromMicrosecondsSinceEpoch(micros),
      Map<Object?, Object?> m => {for (final e in m.entries) e.key as String: _decode(e.value)},
      List<Object?> l => [for (final v in l) _decode(v)],
      _ => value,
    };

/// Commits every 400 writes - Firestore's batch limit is 500.
class _BatchedWrites {
  _BatchedWrites(this._db);

  final FirebaseFirestore _db;
  late WriteBatch _batch = _db.batch();
  var _pending = 0;

  Future<void> set(DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data) async {
    _batch.set(ref, data);
    await _count();
  }

  Future<void> delete(DocumentReference<Map<String, dynamic>> ref) async {
    _batch.delete(ref);
    await _count();
  }

  Future<void> _count() async {
    if (++_pending >= 400) await flush();
  }

  Future<void> flush() async {
    if (_pending == 0) return;
    await _batch.commit();
    _batch = _db.batch();
    _pending = 0;
  }
}
