import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finan2/core/balance/balance_ledger.dart';
import 'package:finan2/core/crypto/household_crypto.dart';

/// A [BalanceLedger] for one named device that returns once its writes are
/// in [firestore], so a test can read the result straight after.
BalanceLedger testBalanceLedger(
  FirebaseFirestore firestore,
  HouseholdCrypto crypto, {
  String device = 'this-phone',
}) => BalanceLedger(
  firestore: firestore,
  crypto: crypto,
  deviceId: () async => device,
  waitForServer: true,
);
