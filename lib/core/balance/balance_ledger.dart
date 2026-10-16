import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../crypto/household_crypto.dart';
import '../observability/error_reporter.dart';

/// Where each device keeps its share of an account's or a debt's balance:
/// `{deviceId: encrypted amount}`, next to the `balance` set by hand.
const deviceBalancesField = 'deviceBalances';

/// An account's or a debt's balance as stored: the `balance` set by hand
/// plus every device's share in [deviceBalancesField].
Future<int> storedBalance(
  Map<String, dynamic> data,
  HouseholdCrypto crypto,
  String householdId,
) async {
  final base = data['balance'] as String?;
  final own = base == null ? 0 : await crypto.decryptAmount(householdId, base);
  return own + await _sharesOf(data, crypto, householdId);
}

Future<int> _sharesOf(Map<String, dynamic> data, HouseholdCrypto crypto, String householdId) async {
  final shares = data[deviceBalancesField];
  if (shares is! Map) return 0;
  var total = 0;
  for (final packed in shares.values) {
    if (packed is String) total += await crypto.decryptAmount(householdId, packed);
  }
  return total;
}

/// Moves balances without asking the server, so money can be recorded with
/// no connection and is sent on its own when it's back.
///
/// The server can't add to an encrypted balance, and two devices rewriting
/// the same one offline would overwrite each other. So each device adds what
/// it moves to its own entry in [deviceBalancesField]: only that device ever
/// writes it, so what its cache holds - its own pending writes included - is
/// always the latest, and the entries of both devices just add up.
class BalanceLedger {
  BalanceLedger({
    FirebaseFirestore? firestore,
    HouseholdCrypto? crypto,
    Future<String> Function()? deviceId,
    this.waitForServer = false,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _crypto = crypto ?? HouseholdCrypto(),
       _deviceId = deviceId ?? _thisDevice;

  final FirebaseFirestore _db;
  final HouseholdCrypto _crypto;
  final Future<String> Function() _deviceId;

  /// Tests: return once every write is committed rather than queued - this
  /// one and the follow-ups of whoever uses this ledger.
  final bool waitForServer;

  /// One read-then-write at a time per database, across every repository:
  /// two quick saves on the same account must not read the same share. Per
  /// database rather than global so a fresh one (a test's) never waits on
  /// another's.
  static final _turns = Expando<Future<void>>();

  /// Applies [deltas] - each a document and the signed change to its
  /// balance - to this device's shares, in [batch] with the record that
  /// causes them, and commits. Documents that no longer exist are skipped:
  /// nothing to adjust.
  ///
  /// Returns once the batch is queued on this device - offline the server
  /// may get it much later, and that never blocks the screen.
  Future<void> commit(
    String householdId,
    List<(DocumentReference<Map<String, dynamic>>, int)> deltas, {
    WriteBatch? batch,
  }) {
    final turn = _turns[_db] ?? Future<void>.value();
    final run = turn.then((_) => _commit(householdId, deltas, batch ?? _db.batch()));
    _turns[_db] = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<void> _commit(
    String householdId,
    List<(DocumentReference<Map<String, dynamic>>, int)> deltas,
    WriteBatch batch,
  ) async {
    final device = await _deviceId();
    final byPath = <String, (DocumentReference<Map<String, dynamic>>, int)>{};
    for (final (ref, delta) in deltas) {
      final previous = byPath[ref.path]?.$2 ?? 0;
      byPath[ref.path] = (ref, previous + delta);
    }

    for (final (ref, delta) in byPath.values) {
      if (delta == 0) continue;
      final snap = await cacheFirst(ref);
      if (!snap.exists) continue;
      final data = snap.data()!;
      final shares = data[deviceBalancesField];
      final packed = shares is Map ? shares[device] : null;
      final mine = packed is String ? await _crypto.decryptAmount(householdId, packed) : 0;
      batch.update(ref, {
        '$deviceBalancesField.$device': await _crypto.encryptAmount(householdId, mine + delta),
        // Debts keep a plaintext «anything left to pay» for the Worker.
        if (data.containsKey('hasBalance'))
          'hasBalance': await storedBalance(data, _crypto, householdId) + delta > 0,
      });
    }

    final committed = batch.commit();
    if (waitForServer) return committed;
    unawaited(
      committed.catchError((Object e, StackTrace st) {
        ErrorReporter.recoverable(e, st, reason: 'balance write rejected by the server');
      }),
    );
  }

  /// Every device's share of [ref]'s balance, so a balance set by hand can
  /// store `balance` as what's left once the shares are added.
  Future<int> sharesOf(String householdId, DocumentReference<Map<String, dynamic>> ref) async {
    final snap = await cacheFirst(ref);
    return _sharesOf(snap.data() ?? const {}, _crypto, householdId);
  }

  /// The cached copy - pending writes included - and the server only if
  /// this device never had it: offline, the server would just fail.
  static Future<DocumentSnapshot<Map<String, dynamic>>> cacheFirst(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      final cached = await ref.get(const GetOptions(source: Source.cache));
      if (cached.exists) return cached;
    } on FirebaseException {
      // Not in the cache.
    }
    return ref.get();
  }

  static const _deviceIdKey = 'balance_device_id';
  static Future<String>? _loaded;

  static Future<String> _thisDevice() => _loaded ??= _loadDevice()
    ..catchError((Object _) {
      _loaded = null; // try again next time
      return '';
    });

  static Future<String> _loadDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_deviceIdKey);
    if (saved != null) return saved;
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final id = String.fromCharCodes(
      List.generate(20, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    await prefs.setString(_deviceIdKey, id);
    return id;
  }
}
