import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Diacritics map for normalization
const Map<String, String> _diacritics = {
  'á':'a','ä':'a','č':'c','ď':'d','é':'e','ě':'e','í':'i',
  'ľ':'l','ĺ':'l','ň':'n','ó':'o','ô':'o','ö':'o',
  'ř':'r','ŕ':'r','š':'s','ť':'t','ú':'u','ů':'u','ü':'u',
  'ý':'y','ž':'z'
};

String normalize(String input) {
  return input
      .toLowerCase()
      .split('')
      .map((c) => _diacritics[c] ?? c)
      .join();
}

Set<String>? globalIgnoredTokens;

Future<void> loadIgnoredTokensGlobal() async {
  final jsonStr = await rootBundle.loadString('lib/data/ignored_ingredient_tokens.json');
  final data = json.decode(jsonStr);
  final List<String> allTokens = [
    ...?data['units'],
    ...?data['amount_words'],
    ...?data['preparation_words'],
    ...?data['qualifiers'],
    ...?data['symbols'],
  ];
  globalIgnoredTokens = allTokens.map(normalize).toSet();
}

Future<Set<String>> loadIgnoredTokens() async {
  final jsonStr = await rootBundle.loadString('lib/data/ignored_ingredient_tokens.json');
  final data = json.decode(jsonStr);
  final List<String> allTokens = [
    ...?data['units'],
    ...?data['amount_words'],
    ...?data['preparation_words'],
    ...?data['qualifiers'],
    ...?data['symbols'],
  ];
  return allTokens.map(normalize).toSet();
}

String filterIngredient(String ingredient, Set<String> ignoredTokens) {
  // Remove numbers, split to tokens (pôvodné slová)
  final noNumbers = ingredient.replaceAll(RegExp(r'[0-9]+'), '');
  final originalTokens = noNumbers
      .split(RegExp(r'\s+|,|;|\(|\)|\.|:|!|\?|\[|\]'))
      .where((t) => t.isNotEmpty)
      .toList();
  // Filtrovať podľa normalizovaných tokenov
  final filtered = originalTokens.where((t) => !ignoredTokens.contains(normalize(t))).toList();
  return filtered.join(' ').trim();
}

// Porovnáva položky do Cart case-insensitive a bez diakritiky
bool cartContainsItem(Iterable<String> cartValues, String item) {
  final normItem = normalize(item);
  return cartValues.any((e) => normalize(e) == normItem);
}
