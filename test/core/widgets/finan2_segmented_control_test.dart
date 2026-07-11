import 'package:finan2/core/widgets/finan2_segmented_control.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

enum _Segment { ingreso, gasto, ahorro }

void main() {
  testWidgets('renders a label for every option', (tester) async {
    await pumpFinan2(
      tester,
      Finan2SegmentedControl<_Segment>(
        options: const {
          _Segment.ingreso: 'Ingreso',
          _Segment.gasto: 'Gasto',
          _Segment.ahorro: 'Ahorro',
        },
        selected: _Segment.gasto,
        onChanged: (_) {},
      ),
    );
    expect(find.text('Ingreso'), findsOneWidget);
    expect(find.text('Gasto'), findsOneWidget);
    expect(find.text('Ahorro'), findsOneWidget);
  });

  testWidgets('calls onChanged with the tapped segment\'s key', (tester) async {
    _Segment? picked;
    await pumpFinan2(
      tester,
      Finan2SegmentedControl<_Segment>(
        options: const {_Segment.ingreso: 'Ingreso', _Segment.gasto: 'Gasto'},
        selected: _Segment.ingreso,
        onChanged: (value) => picked = value,
      ),
    );
    await tester.tap(find.text('Gasto'));
    expect(picked, _Segment.gasto);
  });

  testWidgets('does not call onChanged just from building the widget', (tester) async {
    var called = false;
    await pumpFinan2(
      tester,
      Finan2SegmentedControl<_Segment>(
        options: const {_Segment.ingreso: 'Ingreso', _Segment.gasto: 'Gasto'},
        selected: _Segment.ingreso,
        onChanged: (_) => called = true,
      ),
    );
    expect(called, isFalse);
  });
}
