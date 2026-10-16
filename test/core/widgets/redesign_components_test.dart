import 'package:finan2/core/theme/app_theme.dart';
import 'package:finan2/core/widgets/finan2_amount_input.dart';
import 'package:finan2/core/widgets/finan2_figure.dart';
import 'package:finan2/core/widgets/finan2_nav_bar.dart';
import 'package:finan2/core/widgets/finan2_person_tag.dart';
import 'package:finan2/core/widgets/finan2_progress.dart';
import 'package:finan2/core/widgets/finan2_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child, {ThemeData? theme}) => tester.pumpWidget(
  MaterialApp(
    theme: theme ?? Finan2Theme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('the figure draws the currency sign apart from the digits', (tester) async {
    await _pump(tester, const Finan2Figure(label: 'Les queda', amountText: r'$1.250.000'));

    final rich = tester.widget<RichText>(
      find.descendant(of: find.byType(Finan2Figure), matching: find.byType(RichText)).last,
    );
    final spans = <TextSpan>[];
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) spans.add(span);
      return true;
    });
    expect(spans.map((s) => s.text), [r'$', '1.250.000']);
    expect(spans.first.style!.fontSize, lessThan(spans.last.style!.fontSize!));
  });

  testWidgets('a bar past its budget turns to the over color', (tester) async {
    const colors = Finan2Colors.light;
    Color fill() =>
        (tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: find.byType(FractionallySizedBox),
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration
                as BoxDecoration)
            .color!;

    await _pump(
      tester,
      const SizedBox(width: 200, child: Finan2ProgressBar(fraction: 0.4, color: Colors.teal)),
    );
    expect(fill(), Colors.teal);

    await _pump(
      tester,
      const SizedBox(width: 200, child: Finan2ProgressBar(fraction: 1.2, color: Colors.teal)),
    );
    expect(fill(), colors.expense);
  });

  testWidgets('the ring shows its label', (tester) async {
    await _pump(tester, const Finan2Ring(fraction: 0.4, color: Colors.teal, label: '40%'));
    expect(find.text('40%'), findsOneWidget);
  });

  testWidgets('a person tag uses the member color in each theme', (tester) async {
    for (final (theme, colors) in [
      (Finan2Theme.light, Finan2Colors.light),
      (Finan2Theme.dark, Finan2Colors.dark),
    ]) {
      await _pump(tester, const Finan2PersonTag(label: 'Vale', memberIndex: 1), theme: theme);
      await tester.pumpAndSettle(); // the theme change animates
      expect(tester.widget<Text>(find.text('Vale')).style!.color, colors.userB);
    }
  });

  testWidgets('the segmented control reports the tapped option', (tester) async {
    var selected = 'gasto';
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Finan2SegmentedControl<String>(
          options: const {'gasto': 'Gasto', 'ingreso': 'Ingreso'},
          dots: const {'gasto': Colors.red},
          selected: selected,
          onChanged: (value) => setState(() => selected = value),
        ),
      ),
    );
    await tester.tap(find.text('Ingreso'));
    await tester.pump();
    expect(selected, 'ingreso');
    expect(tester.widget<Text>(find.text('Ingreso')).style!.color, Finan2Colors.light.ink);
  });

  testWidgets('the nav bar keeps its height and routes each tap', (tester) async {
    int? selected;
    var added = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: Finan2Theme.light,
        home: Scaffold(
          bottomNavigationBar: Finan2NavBar(
            items: const [
              Finan2NavItem(icon: Icon(Icons.home), label: 'Inicio'),
              Finan2NavItem(icon: Icon(Icons.list), label: 'Movimientos'),
              Finan2NavItem(icon: Icon(Icons.donut_large), label: 'Plan'),
              Finan2NavItem(icon: Icon(Icons.settings), label: 'Ajustes'),
            ],
            selectedIndex: 0,
            onSelected: (i) => selected = i,
            addLabel: 'Anotar',
            onAdd: () => added++,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Finan2NavBar)).height, lessThan(120));
    await tester.tap(find.text('Plan'));
    expect(selected, 2);
    await tester.tap(find.byTooltip('Anotar'));
    expect(added, 1);
  });

  testWidgets('the amount groups digits as typed and parses back', (tester) async {
    final controller = TextEditingController(text: '1250000');
    addTearDown(controller.dispose);
    await _pump(tester, Finan2AmountInput(controller: controller));
    expect(controller.text, '1.250.000'); // a prefilled amount is grouped too

    await tester.enterText(find.byType(TextField), '98765');
    expect(controller.text, '98.765');
    expect(Finan2AmountInput.parse(controller.text), 98765);
    expect(Finan2AmountInput.parse(''), isNull);
  });
}
