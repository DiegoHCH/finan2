import 'package:finan2/core/locale/app_language.dart';
import 'package:finan2/core/theme/theme_mode_providers.dart';
import 'package:finan2/features/app_lock/presentation/viewmodels/app_lock_providers.dart';
import 'package:finan2/features/household/presentation/viewmodels/household_providers.dart';
import 'package:finan2/features/profile/presentation/profile_providers.dart';
import 'package:finan2/features/settings/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_screen.dart';
import '../../helpers/test_app_container.dart';

Future<Map<String, dynamic>?> _profileDoc(TestApp app) async =>
    (await app.firestore.doc('users/$testUid').get()).data();

/// Starts the sync the way the AuthGate does and lets it settle.
Future<void> _sync(WidgetTester tester, TestApp app) async {
  app.container.listen(profileSyncProvider, (_, _) {});
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the first sign-in creates the profile with this phone\'s preferences', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await _sync(tester, app);

    final doc = (await tester.runAsync(() => _profileDoc(app)))!;
    expect(doc['name'], 'Diego');
    expect(doc['email'], 'diego@example.com');
    expect(doc['theme'], 'system');
    expect(doc['language'], 'system');
  });

  testWidgets('a new phone takes the account\'s language and theme', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(
      () => app.firestore.doc('users/$testUid').set({
        'name': 'Diego',
        'email': 'diego@example.com',
        'language': 'en',
        'theme': 'dark',
      }),
    );
    await _sync(tester, app);

    expect(app.container.read(themeModeControllerProvider).value, ThemeMode.dark);
    expect(app.container.read(appLanguageControllerProvider).value, AppLanguage.en);
  });

  testWidgets('changing the theme here saves it to the account', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await _sync(tester, app);

    await tester.runAsync(
      () => app.container.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.light),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    expect((await tester.runAsync(() => _profileDoc(app)))!['theme'], 'light');
  });

  testWidgets('Tu perfil: the name changes in the profile and in the household', (tester) async {
    final app = (await tester.runAsync(TestApp.start))!;
    await tester.runAsync(
      () => app.firestore.doc('households/$testHouseholdId').set({
        'name': 'Casa',
        'members': [testUid],
        'memberInfo': {
          testUid: {'name': 'Diego'},
        },
      }),
    );
    await _sync(tester, app);
    await pumpScreen(tester, app, const ProfileScreen());

    expect(find.text('diego@example.com'), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
    await tester.tap(find.text('Nombre'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'diego andrés');
    await tester.tap(find.text('Guardar'));
    await settle(tester);

    expect((await tester.runAsync(() => _profileDoc(app)))!['name'], 'Diego Andrés');
    expect(app.auth.displayName, 'Diego Andrés');

    await tester.tap(find.text('Cambiar contraseña'));
    await settle(tester);
    expect(app.auth.passwordResets, ['diego@example.com']);
    expect(find.text('Revisa tu correo'), findsOneWidget);
    expect(find.text('Algo salió mal'), findsNothing);
    final household = await tester.runAsync(
      () => app.firestore.doc('households/$testHouseholdId').get(),
    );
    expect(household!.data()?['memberInfo']?[testUid]?['name'], 'Diego Andrés');
  });

  testWidgets('deleting the account takes the profile and the PIN with it', (tester) async {
    final app = (await tester.runAsync(
      () => TestApp.start(withHousehold: false, slowCloud: true),
    ))!;
    await _sync(tester, app);
    await tester.runAsync(() => app.container.read(appLockRepositoryProvider).setPin('2580'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    expect(
      (await tester.runAsync(
        () => app.firestore.doc('users/$testUid/private/appLock').get(),
      ))!.exists,
      isTrue,
    );

    // Checked the moment the account goes: anything left after that can't
    // be deleted any more - the rules need someone signed in.
    bool? pinLeft;
    Map<String, dynamic>? profileLeft;
    app.auth.onDelete = () async {
      pinLeft = (await app.firestore.doc('users/$testUid/private/appLock').get()).exists;
      profileLeft = await _profileDoc(app);
    };
    await tester.runAsync(
      () => app.container.read(householdControllerProvider.notifier).deleteAccount(),
    );

    expect(pinLeft, isFalse);
    expect(profileLeft, isNull);
    expect(app.auth.deleted, isTrue);
  });
}
