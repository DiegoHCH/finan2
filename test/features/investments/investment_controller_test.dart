import 'package:finan2/features/investments/data/investment_model.dart';
import 'package:finan2/features/investments/presentation/viewmodels/investment_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  Investment cdt({String id = '', int value = 1050000}) => Investment(
    id: id,
    name: 'CDT',
    kind: InvestmentKind.rentaFija,
    rate: 11.5,
    investedAmount: 1000000,
    currentValue: value,
  );

  test('save creates, then updates the same investment', () async {
    final controller = app.container.read(investmentControllerProvider.notifier);
    await controller.save(cdt());
    final created = (await app.first(investmentsProvider)).single;

    await controller.save(cdt(id: created.id, value: 1100000));

    final saved = (await app.first(investmentsProvider)).single;
    expect(saved.id, created.id);
    expect(saved.currentValue, 1100000);
    expect(app.container.read(totalInvestmentValueProvider), 1100000);
  });

  test('amounts are stored encrypted', () async {
    await app.container.read(investmentControllerProvider.notifier).save(cdt());

    final doc = (await app.docs('investments')).single;
    expect(doc['currentValue'], isNot(1050000));
    expect(doc['currentValue'], isA<String>());
  });

  test('delete removes it', () async {
    final controller = app.container.read(investmentControllerProvider.notifier);
    await controller.save(cdt());
    await controller.delete((await app.first(investmentsProvider)).single.id);

    expect(await app.docs('investments'), isEmpty);
  });
}
