/// Title-cases every word in [input] (first letter up, rest down) and
/// collapses repeated whitespace - "tarjeta  VISA" -> "Tarjeta Visa". Used to
/// normalize every name/description field right before it's saved, so a
/// household's data stays consistently capitalized no matter how each
/// member happened to type it in.
String toTitleCase(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed
      .split(RegExp(r'\s+'))
      .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

/// [input] with only its first letter up - «agosto – octubre 2026» ->
/// «Agosto – octubre 2026».
String capitalizeFirst(String input) =>
    input.isEmpty ? input : '${input[0].toUpperCase()}${input.substring(1)}';
