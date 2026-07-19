import 'package:finan2/core/utils/text_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('title-cases a lowercase multi-word string', () {
    expect(toTitleCase('tarjeta visa'), 'Tarjeta Visa');
  });

  test('title-cases an all-uppercase string', () {
    expect(toTitleCase('TARJETA VISA'), 'Tarjeta Visa');
  });

  test('title-cases a mixed-case string', () {
    expect(toTitleCase('tArJeTa VISA'), 'Tarjeta Visa');
  });

  test('a single word is capitalized', () {
    expect(toTitleCase('mercado'), 'Mercado');
  });

  test('trims leading/trailing whitespace', () {
    expect(toTitleCase('  viaje a europa  '), 'Viaje A Europa');
  });

  test('collapses repeated internal whitespace to a single space', () {
    expect(toTitleCase('viaje   a    europa'), 'Viaje A Europa');
  });

  test('handles Spanish accented letters', () {
    expect(toTitleCase('crédito móvil ñoño'), 'Crédito Móvil Ñoño');
  });

  test('an empty or whitespace-only string stays empty', () {
    expect(toTitleCase(''), '');
    expect(toTitleCase('   '), '');
  });

  test('already title-cased text is left as-is', () {
    expect(toTitleCase('Tarjeta Visa'), 'Tarjeta Visa');
  });
}
