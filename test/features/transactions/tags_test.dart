import 'package:finan2/features/categories/data/category_model.dart';
import 'package:finan2/features/transactions/data/movement_filter.dart';
import 'package:finan2/features/transactions/data/tags.dart';
import 'package:finan2/features/transactions/data/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _tx(List<String> tags, {String id = 't'}) => Movement(
      id: id,
      amount: 1000,
      type: CategoryType.gasto,
      categoryId: 'c',
      accountId: 'a',
      description: '',
      date: DateTime(2026, 10, 1),
      createdBy: 'u1',
      tags: tags,
    );

void main() {
  test('normalizeTag lowercases, drops # and joins words', () {
    expect(normalizeTag('  #Viaje Cartagena '), 'viaje-cartagena');
    expect(normalizeTag('##cumple'), 'cumple');
    expect(normalizeTag('   '), '');
    expect(normalizeTag('a' * 40), hasLength(maxTagLength));
  });

  test('tagsByUse puts the most used first, ties alphabetically', () {
    expect(
      tagsByUse([
        _tx(['viaje', 'playa']),
        _tx(['viaje']),
        _tx(['cumple']),
      ]),
      ['viaje', 'cumple', 'playa'],
    );
  });

  test('the filter narrows by tag', () {
    const filter = MovementFilter(tag: 'viaje');
    expect(filter.activeFilterCount, 1);
    expect(filter.matches(_tx(['viaje', 'playa'])), isTrue);
    expect(filter.matches(_tx(['playa'])), isFalse);
  });

  test('the search finds tags, with or without #', () {
    expect(const MovementFilter(query: '#viaj').matches(_tx(['viaje'])), isTrue);
    expect(const MovementFilter(query: 'viaje').matches(_tx(['viaje'])), isTrue);
    expect(const MovementFilter(query: '#').matches(_tx(['viaje'])), isFalse);
  });
}
