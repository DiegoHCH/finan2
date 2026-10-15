import 'package:finan2/features/monthly_notes/presentation/viewmodels/monthly_notes_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_container.dart';

void main() {
  test('saves this month\'s note and next month\'s reminder', () async {
    final app = await TestApp.start();
    final controller = app.container.read(monthlyNotesControllerProvider.notifier);

    await controller.saveThisMonth('Pagar la prima');
    await controller.saveNextMonth('Revisar el seguro');

    final notes = await app.first(currentMonthNotesProvider);
    expect(notes.thisMonth, 'Pagar la prima');
    expect(notes.nextMonth, 'Revisar el seguro');
  });
}
