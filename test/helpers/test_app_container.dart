import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:finan2/core/crypto/household_crypto.dart';
import 'package:finan2/core/notifications/notification_providers.dart';
import 'package:finan2/core/notifications/push_service.dart';
import 'package:finan2/features/accounts/data/account_repository.dart';
import 'package:finan2/features/accounts/presentation/viewmodels/account_providers.dart';
import 'package:finan2/features/app_lock/data/app_lock_cloud.dart';
import 'package:finan2/features/app_lock/data/app_lock_repository.dart';
import 'package:finan2/features/app_lock/presentation/viewmodels/app_lock_providers.dart';
import 'package:finan2/features/auth/data/auth_repository.dart';
import 'package:finan2/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:finan2/features/budget/data/budget_repository.dart';
import 'package:finan2/features/budget/presentation/viewmodels/budget_providers.dart';
import 'package:finan2/features/categories/data/category_repository.dart';
import 'package:finan2/features/categories/presentation/viewmodels/category_providers.dart';
import 'package:finan2/features/connection/data/connection_repository.dart';
import 'package:finan2/features/connection/presentation/viewmodels/connection_providers.dart';
import 'package:finan2/features/debts/data/card_payment_repository.dart';
import 'package:finan2/features/debts/data/debt_repository.dart';
import 'package:finan2/features/debts/presentation/viewmodels/card_payment_providers.dart';
import 'package:finan2/features/debts/presentation/viewmodels/debt_providers.dart';
import 'package:finan2/features/household/data/household_model.dart';
import 'package:finan2/features/household/data/household_repository.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:finan2/features/investments/data/investment_repository.dart';
import 'package:finan2/features/investments/presentation/viewmodels/investment_providers.dart';
import 'package:finan2/features/monthly_notes/data/monthly_notes_repository.dart';
import 'package:finan2/features/monthly_notes/presentation/viewmodels/monthly_notes_providers.dart';
import 'package:finan2/features/notification_prefs/data/notification_prefs_repository.dart';
import 'package:finan2/features/notification_prefs/presentation/viewmodels/notification_prefs_providers.dart';
import 'package:finan2/features/notifications/data/notification_repository.dart';
import 'package:finan2/features/notifications/presentation/viewmodels/notification_providers.dart';
import 'package:finan2/features/profile/data/user_profile_repository.dart';
import 'package:finan2/features/profile/presentation/profile_providers.dart';
import 'package:finan2/features/recurring_bills/data/recurring_bill_repository.dart';
import 'package:finan2/features/recurring_bills/presentation/viewmodels/recurring_bill_providers.dart';
import 'package:finan2/features/savings_challenge/data/savings_challenge_repository.dart';
import 'package:finan2/features/savings_challenge/presentation/viewmodels/savings_challenge_providers.dart';
import 'package:finan2/features/savings_goals/data/savings_goal_repository.dart';
import 'package:finan2/features/savings_goals/presentation/viewmodels/savings_goal_providers.dart';
import 'package:finan2/features/transactions/data/transaction_repository.dart';
import 'package:finan2/features/transactions/presentation/viewmodels/transaction_providers.dart';
import 'package:finan2/features/transfers/data/transfer_repository.dart';
import 'package:finan2/features/transfers/presentation/viewmodels/transfer_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';

import 'test_balance_ledger.dart';
import 'fake_biometric_unlock.dart';
import 'test_household_crypto.dart';

const testHouseholdId = 'h1';
const testUid = 'u1';

class FakeUser extends Fake implements User {
  FakeUser(this.uid, {this.displayName = 'Diego'});

  @override
  final String uid;

  @override
  final String? displayName;

  @override
  String? get email => 'diego@example.com';

  @override
  UserMetadata get metadata => _FakeMetadata(accountCreatedAt);
}

/// When [FakeUser]'s account was created: movements can't be dated before
/// this month.
final accountCreatedAt = DateTime(2026, 9, 12);

/// When the test household was created: after the account, as when a
/// partner set it up later.
final householdCreatedAt = DateTime(2026, 10, 3);

class _FakeMetadata extends Fake implements UserMetadata {
  _FakeMetadata(this.creationTime);

  @override
  final DateTime? creationTime;
}

/// Never reaches FCM or the Worker.
/// Auth without Firebase: what the screens ask of it, recorded.
class FakeAuthRepository extends Fake implements AuthRepository {
  String? displayName;

  /// Firebase's live user, as opposed to the sign-in's snapshot.
  @override
  User? currentUser;
  final passwordResets = <String>[];

  @override
  bool get signedInWithGoogle => false;

  @override
  Future<void> updateDisplayName(String name) async => displayName = name;

  @override
  Future<void> sendPasswordResetEmail(String email) async => passwordResets.add(email);

  var deleted = false;

  /// Runs as the account goes - after it nothing signed in can write.
  Future<void> Function()? onDelete;

  @override
  Future<void> deleteAccount() async {
    await onDelete?.call();
    deleted = true;
  }
}

class FakePushService extends Fake implements PushService {
  /// Whether the OS allows notifications; [grantOnRequest] whether the
  /// prompt, when shown, is answered «Allow».
  bool allowed = false;
  bool grantOnRequest = true;
  var requests = 0;

  @override
  Future<bool> notificationsAllowed() async => allowed;

  @override
  Future<bool> requestNotificationPermission() async {
    requests++;
    return allowed = allowed || grantOnRequest;
  }

  @override
  Future<void> registerToken(String householdId, String uid) async {}

  @override
  Future<void> sendPush({
    required String householdId,
    required String excludeUid,
    required String title,
    required String body,
  }) async {}
}

/// A signed-in member of [testHouseholdId] with every repository writing to
/// [firestore] - what a controller test needs to drive the real data layer
/// without Firebase.
class TestApp {
  TestApp._(this.container, this.firestore, this.crypto, this.push, this.biometrics, this.auth);

  /// The same fakes behind [container] - a child of [app]'s with a few
  /// overrides of its own (a sign-in stream to drive, say).
  TestApp.withContainer(TestApp app, this.container)
    : firestore = app.firestore,
      crypto = app.crypto,
      push = app.push,
      biometrics = app.biometrics,
      auth = app.auth;

  final ProviderContainer container;
  final FakeFirebaseFirestore firestore;
  final HouseholdCrypto crypto;
  final FakePushService push;
  final FakeBiometricUnlock biometrics;
  final FakeAuthRepository auth;

  /// With [withHousehold] false the member has none yet: the household
  /// comes from the fake Firestore, so creating one in the app shows it.
  ///
  /// [withPin] false is a phone this account never set up (the AuthGate
  /// shows the onboarding first); true (the default) is one already set up.
  ///
  /// [slowCloud] makes the PIN's cloud copy answer the way the network does,
  /// a moment later, instead of right away.
  static Future<TestApp> start({
    bool withHousehold = true,
    bool withPin = true,
    bool slowCloud = false,
  }) async {
    final firestore = FakeFirebaseFirestore();
    final crypto = await testHouseholdCrypto(testHouseholdId);
    final ledger = testBalanceLedger(firestore, crypto);
    final push = FakePushService();
    final biometrics = FakeBiometricUnlock();
    final auth = FakeAuthRepository();
    final appLock = AppLockRepository(
      account: testUid,
      cloud: slowCloud
          ? _SlowCloud(FirestoreAppLockCloud(firestore: firestore))
          : FirestoreAppLockCloud(firestore: firestore),
      store: InMemoryKeyStore(),
    );
    if (withPin) {
      await appLock.setPin('1397');
      await appLock.markOnboarded();
    }
    final container = ProviderContainer(
      overrides: [
        authStateChangesProvider.overrideWith((ref) => Stream<User?>.value(FakeUser(testUid))),
        authRepositoryProvider.overrideWithValue(auth),
        if (withHousehold)
          currentHouseholdProvider.overrideWith(
            (ref) => Stream<Household?>.value(
              Household(
                id: testHouseholdId,
                name: 'Casa',
                members: const [testUid],
                memberInfo: const {},
                currency: 'COP',
                startYear: 2026,
                weekStartsOn: 'monday',
                createdAt: householdCreatedAt,
              ),
            ),
          ),
        householdCryptoProvider.overrideWithValue(crypto),
        appLockRepositoryProvider.overrideWithValue(appLock),
        biometricUnlockProvider.overrideWithValue(biometrics),
        pushServiceProvider.overrideWithValue(push),
        foregroundPushesProvider.overrideWithValue(const Stream.empty()),
        householdRepositoryProvider.overrideWithValue(HouseholdRepository(firestore: firestore)),
        userProfileRepositoryProvider.overrideWithValue(
          UserProfileRepository(firestore: firestore),
        ),
        connectionRepositoryProvider.overrideWithValue(ConnectionRepository(firestore: firestore)),
        notificationRepositoryProvider.overrideWithValue(
          NotificationRepository(firestore: firestore),
        ),
        notificationPrefsRepositoryProvider.overrideWithValue(
          NotificationPrefsRepository(firestore: firestore),
        ),
        accountRepositoryProvider.overrideWithValue(
          AccountRepository(firestore: firestore, crypto: crypto, ledger: ledger),
        ),
        budgetRepositoryProvider.overrideWithValue(
          BudgetRepository(firestore: firestore, crypto: crypto),
        ),
        categoryRepositoryProvider.overrideWithValue(CategoryRepository(firestore: firestore)),
        cardPaymentRepositoryProvider.overrideWithValue(
          CardPaymentRepository(firestore: firestore, crypto: crypto, ledger: ledger),
        ),
        debtRepositoryProvider.overrideWithValue(
          DebtRepository(firestore: firestore, crypto: crypto, ledger: ledger),
        ),
        investmentRepositoryProvider.overrideWithValue(
          InvestmentRepository(firestore: firestore, crypto: crypto),
        ),
        monthlyNotesRepositoryProvider.overrideWithValue(
          MonthlyNotesRepository(firestore: firestore),
        ),
        recurringBillRepositoryProvider.overrideWithValue(
          RecurringBillRepository(firestore: firestore, crypto: crypto),
        ),
        savingsChallengeRepositoryProvider.overrideWithValue(
          SavingsChallengeRepository(firestore: firestore, crypto: crypto),
        ),
        savingsGoalRepositoryProvider.overrideWithValue(
          SavingsGoalRepository(firestore: firestore, crypto: crypto),
        ),
        transactionRepositoryProvider.overrideWithValue(
          TransactionRepository(firestore: firestore, crypto: crypto, ledger: ledger),
        ),
        transferRepositoryProvider.overrideWithValue(
          TransferRepository(firestore: firestore, crypto: crypto, ledger: ledger),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Controllers read these with ref.read, so they must have a value first.
    container.listen(authStateChangesProvider, (_, _) {});
    container.listen(currentHouseholdProvider, (_, _) {});
    await container.read(authStateChangesProvider.future);
    await container.read(currentHouseholdProvider.future);
    return TestApp._(container, firestore, crypto, push, biometrics, auth);
  }

  /// The household's `collection`, for asserting what a controller wrote.
  Future<List<Map<String, dynamic>>> docs(String collection) async {
    final snap = await firestore.collection('households/$testHouseholdId/$collection').get();
    return [for (final d in snap.docs) d.data()];
  }

  /// The IDs in the household's `collection`.
  Future<List<String>> ids(String collection) async {
    final snap = await firestore.collection('households/$testHouseholdId/$collection').get();
    return [for (final d in snap.docs) d.id];
  }

  /// Reads a stream provider after letting pending writes reach it - the
  /// fake Firestore delivers snapshots asynchronously.
  Future<T> first<T>(ProviderListenable<AsyncValue<T>> provider) async {
    final sub = container.listen(provider, (_, _) {}, fireImmediately: true);
    await pumpEventQueue();
    while (sub.read().isLoading) {
      await pumpEventQueue();
    }
    return sub.read().requireValue;
  }
}

class _SlowCloud implements AppLockCloud {
  _SlowCloud(this._cloud);

  final AppLockCloud _cloud;
  static const _latency = Duration(milliseconds: 50);

  @override
  Future<String?> fetch(String account) => _cloud.fetch(account);

  @override
  Future<void> save(String account, String record) =>
      Future<void>.delayed(_latency, () => _cloud.save(account, record));

  @override
  Future<void> delete(String account) =>
      Future<void>.delayed(_latency, () => _cloud.delete(account));
}
