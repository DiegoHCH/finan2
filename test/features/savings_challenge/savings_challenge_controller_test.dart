import 'package:finan2/features/savings_challenge/presentation/viewmodels/savings_challenge_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  test('a new challenge starts with no cell done and belongs to its creator', () async {
    await app.container.read(savingsChallengeControllerProvider.notifier).create('52 semanas', [
      1000,
      2000,
      3000,
    ]);

    final challenge = (await app.first(savingsChallengeProvider))!;
    expect(challenge.cellAmounts, [1000, 2000, 3000]);
    expect(challenge.done, [false, false, false]);
    expect(challenge.createdBy, testUid);
  });

  test('toggling cells and deleting', () async {
    final controller = app.container.read(savingsChallengeControllerProvider.notifier);
    await controller.create('Reto', [1000, 2000]);
    final id = (await app.first(savingsChallengeProvider))!.id;

    await controller.toggleCell(id, [true, false]);
    expect((await app.first(savingsChallengeProvider))!.done, [true, false]);

    await controller.delete(id);
    expect(await app.docs('savingsChallenges'), isEmpty);
  });
}
