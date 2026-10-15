import 'package:finan2/features/auth/data/auth_repository.dart';
import 'package:finan2/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this.resetError);

  final FirebaseAuthException? resetError;
  final resetsSent = <String>[];

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (resetError != null) throw resetError!;
    resetsSent.add(email);
  }

  @override
  Future<UserCredential> signInWithEmail({required String email, required String password}) {
    throw FirebaseAuthException(code: 'invalid-credential');
  }
}

ProviderContainer _container(AuthRepository repo) {
  final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('a reset for an unknown email looks the same as a sent one', () async {
    final container = _container(
      _FakeAuthRepository(FirebaseAuthException(code: 'user-not-found')),
    );

    await container.read(authControllerProvider.notifier).sendPasswordReset('nadie@x.co');

    expect(container.read(authControllerProvider).error, isNull);
  });

  test('a reset sends the email', () async {
    final repo = _FakeAuthRepository(null);
    final container = _container(repo);

    await container.read(authControllerProvider.notifier).sendPasswordReset('vale@x.co');

    expect(repo.resetsSent, ['vale@x.co']);
  });

  test('any other reset failure is reported', () async {
    final container = _container(
      _FakeAuthRepository(FirebaseAuthException(code: 'too-many-requests')),
    );

    await container.read(authControllerProvider.notifier).sendPasswordReset('vale@x.co');

    expect(
      container.read(authControllerProvider).error,
      isA<FirebaseAuthException>().having((e) => e.code, 'code', 'too-many-requests'),
    );
  });

  test('a failed sign-in lands in the state instead of throwing', () async {
    final container = _container(_FakeAuthRepository(null));

    await container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'vale@x.co', password: 'mal');

    expect(container.read(authControllerProvider).error, isA<FirebaseAuthException>());
  });
}
