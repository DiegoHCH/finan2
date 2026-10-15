import 'package:finan2/core/crypto/recovery_phrase.dart';
import 'package:finan2/core/crypto/recovery_wordlist_es.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the wordlist has 2048 words', () {
    expect(recoveryWordlistEs, hasLength(2048));
    expect(recoveryWordlistEs.toSet(), hasLength(2048));
  });

  test('a generated phrase has 12 words and parses back to the same entropy', () async {
    final phrase = await RecoveryPhrase.generate();
    expect(phrase.words, hasLength(12));
    expect(phrase.entropy, hasLength(16));

    final parsed = await RecoveryPhrase.parse(phrase.words.join(' '));
    expect(parsed.entropy, phrase.entropy);
    expect(parsed.words, phrase.words);
  });

  test('matches the BIP39 encoding of all-zero entropy', () async {
    // 128 zero bits encode as eleven times word 0 plus the word carrying
    // the checksum (SHA-256 of 16 zero bytes starts with 0x3, index 3).
    final words = [...List.filled(11, recoveryWordlistEs[0]), recoveryWordlistEs[3]];
    final parsed = await RecoveryPhrase.parse(words.join(' '));
    expect(parsed.entropy, List.filled(16, 0));
  });

  test('ignores case, accents, decomposed accents and extra spaces', () async {
    final phrase = await RecoveryPhrase.generate();
    String strip(String w) => w
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');

    final plain = '  ${phrase.words.map(strip).join('   ').toUpperCase()}\n';
    expect((await RecoveryPhrase.parse(plain)).entropy, phrase.entropy);

    // "a" + U+0301 instead of a precomposed "á".
    final decomposed = phrase.words.map((w) => w.replaceAll('á', 'á')).join(' ');
    expect((await RecoveryPhrase.parse(decomposed)).entropy, phrase.entropy);
  });

  test('rejects the wrong word count', () async {
    final phrase = await RecoveryPhrase.generate();
    expect(
      () => RecoveryPhrase.parse(phrase.words.take(11).join(' ')),
      throwsA(isA<RecoveryPhraseFormatException>()),
    );
  });

  test('rejects a word outside the list', () async {
    final phrase = await RecoveryPhrase.generate();
    final words = [...phrase.words]..[4] = 'finan2';
    expect(
      () => RecoveryPhrase.parse(words.join(' ')),
      throwsA(isA<RecoveryPhraseFormatException>()),
    );
  });

  test('rejects swapped words through the checksum', () async {
    // Swapping two different words keeps every word valid but almost always
    // breaks the 4-bit checksum; try until one breaks it (1 in 16 doesn't).
    var rejected = false;
    for (var i = 0; i < 20 && !rejected; i++) {
      final phrase = await RecoveryPhrase.generate();
      if (phrase.words[0] == phrase.words[1]) continue;
      final words = [...phrase.words];
      final first = words[0];
      words[0] = words[1];
      words[1] = first;
      try {
        await RecoveryPhrase.parse(words.join(' '));
      } on RecoveryPhraseFormatException {
        rejected = true;
      }
    }
    expect(rejected, isTrue);
  });
}
