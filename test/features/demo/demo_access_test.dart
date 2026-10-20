import 'package:finan2/features/demo/data/demo_access_repository.dart';
import 'package:finan2/features/demo/presentation/demo_data_actions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Switch extends DemoAccessRepository {
  const _Switch(this.on);

  final bool on;

  @override
  Future<bool> dummyDataEnabled() async => on;
}

void main() {
  test('without Firebase the test-data rows stay hidden', () async {
    expect(await const DemoAccessRepository().dummyDataEnabled(), isFalse);
  });

  Future<bool> enabledWhen(bool dummyData) {
    final container = ProviderContainer(
      overrides: [demoAccessRepositoryProvider.overrideWithValue(_Switch(dummyData))],
    );
    addTearDown(container.dispose);
    // Listened to, as Ajustes does: an unwatched provider is paused.
    container.listen(demoDataEnabledProvider, (_, _) {});
    return container.read(demoDataEnabledProvider.future);
  }

  test('the rows follow dummyData in Remote Config', () async {
    expect(await enabledWhen(true), isTrue);
    expect(await enabledWhen(false), isFalse);
  });
}
