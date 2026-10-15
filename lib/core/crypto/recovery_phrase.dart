import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../../l10n/l10n.dart';
import 'recovery_wordlist_es.dart';

/// Thrown by [RecoveryPhrase.parse] when what the user typed isn't a valid
/// phrase. [message] is ready to show as-is.
class RecoveryPhraseFormatException implements Exception {
  const RecoveryPhraseFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A 12-word recovery phrase (BIP39 encoding over the Spanish wordlist):
/// 128 random bits plus a 4-bit checksum. That's far beyond what an offline
/// guessing sweep can cover, unlike the 6-digit PIN it replaces - so the
/// wrapped key can sit in Firestore readable by members without any
/// attempt counter standing between it and a brute force.
class RecoveryPhrase {
  RecoveryPhrase._(this.entropy, this.words);

  static const wordCount = 12;
  static const _entropyBytes = 16;

  /// The 16 secret bytes the phrase encodes - the input to the key-wrapping
  /// KDF, never stored anywhere.
  final List<int> entropy;
  final List<String> words;

  static final Map<String, int> _indexByWord = {
    for (var i = 0; i < recoveryWordlistEs.length; i++) _normalizeWord(recoveryWordlistEs[i]): i,
  };

  static Future<RecoveryPhrase> generate() async {
    final rand = Random.secure();
    final entropy = List<int>.generate(_entropyBytes, (_) => rand.nextInt(256));
    return RecoveryPhrase._(entropy, await _encode(entropy));
  }

  /// Parses what the user typed. Case, accents and extra spaces don't
  /// matter. Throws [RecoveryPhraseFormatException] on a wrong word count,
  /// an unknown word or a checksum mismatch (most likely a typo).
  static Future<RecoveryPhrase> parse(String input) async {
    final typed = input
        .trim()
        .split(RegExp(r'[\s,.;]+'))
        .where((w) => w.isNotEmpty)
        .map(_normalizeWord)
        .toList();
    if (typed.length != wordCount) {
      throw RecoveryPhraseFormatException(
        currentL10n.errorRecoveryPhraseWordCount(wordCount, typed.length),
      );
    }

    final indices = <int>[];
    for (final word in typed) {
      final index = _indexByWord[word];
      if (index == null) {
        throw RecoveryPhraseFormatException(currentL10n.errorRecoveryPhraseUnknownWord(word));
      }
      indices.add(index);
    }

    // 12 words x 11 bits = 132 bits: 128 of entropy + 4 of checksum.
    var bits = BigInt.zero;
    for (final index in indices) {
      bits = (bits << 11) | BigInt.from(index);
    }
    final checksum = (bits & BigInt.from(0xF)).toInt();
    bits >>= 4;
    final entropy = List<int>.generate(
      _entropyBytes,
      (i) => ((bits >> (8 * (_entropyBytes - 1 - i))) & BigInt.from(0xFF)).toInt(),
    );
    if (await _checksum(entropy) != checksum) {
      throw RecoveryPhraseFormatException(currentL10n.errorRecoveryPhraseInvalid);
    }
    return RecoveryPhrase._(entropy, [for (final i in indices) recoveryWordlistEs[i]]);
  }

  static Future<List<String>> _encode(List<int> entropy) async {
    var bits = BigInt.zero;
    for (final byte in entropy) {
      bits = (bits << 8) | BigInt.from(byte);
    }
    bits = (bits << 4) | BigInt.from(await _checksum(entropy));
    return List<String>.generate(wordCount, (i) {
      final shift = 11 * (wordCount - 1 - i);
      return recoveryWordlistEs[((bits >> shift) & BigInt.from(0x7FF)).toInt()];
    });
  }

  /// First 4 bits of SHA-256(entropy), as in BIP39.
  static Future<int> _checksum(List<int> entropy) async {
    final hash = await Sha256().hash(entropy);
    return hash.bytes.first >> 4;
  }

  static String _normalizeWord(String word) {
    const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n'};
    final buffer = StringBuffer();
    for (final rune in word.toLowerCase().runes) {
      // Combining marks (U+0300-U+036F): a decomposed "á" is "a" + U+0301.
      if (rune >= 0x300 && rune <= 0x36F) continue;
      final char = String.fromCharCode(rune);
      buffer.write(accents[char] ?? char);
    }
    return buffer.toString();
  }
}
