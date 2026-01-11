import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Mapovanie diakritických znakov na ich základné tvary pre normalizáciu
const Map<String, String> _diacritics = {
  'á':'a','ä':'a','č':'c','ď':'d','é':'e','ě':'e','í':'i',
  'ľ':'l','ĺ':'l','ň':'n','ó':'o','ô':'o','ö':'o',
  'ř':'r','ŕ':'r','š':'s','ť':'t','ú':'u','ů':'u','ü':'u',
  'ý':'y','ž':'z'
};

// Funkcia na normalizáciu reťazca (malé písmená, odstránenie diakritiky)
String normalize(String input) {
  return input
      .toLowerCase()
      .split('')
      .map((c) => _diacritics[c] ?? c)
      .join();
}

// Globálna množina ignorovaných tokenov (slová, ktoré sa majú ignorovať pri filtrovaní ingrediencií)
Set<String>? globalIgnoredTokens;

// Načíta ignorované tokeny do globálnej premennej (asynchrónne)
Future<void> loadIgnoredTokensGlobal() async {
  final jsonStr = await rootBundle.loadString('lib/data/ignored_ingredient_tokens.json');
  final data = json.decode(jsonStr);
  // Spojí všetky kategórie tokenov do jedného zoznamu
  final List<String> allTokens = [
    ...?data['units'],
    ...?data['amount_words'],
    ...?data['preparation_words'],
    ...?data['qualifiers'],
    ...?data['symbols'],
  ];
  // Normalizuje a uloží do globálnej množiny
  globalIgnoredTokens = allTokens.map(normalize).toSet();
}

// Načíta ignorované tokeny a vráti ich ako množinu (bez použitia globálnej premennej)
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

// Filtrovanie ingrediencie – odstráni čísla a ignorované slová (tokeny)
String filterIngredient(String ingredient, Set<String> ignoredTokens) {
  // Odstráni čísla, rozdelí na tokeny (slová)
  final noNumbers = ingredient.replaceAll(RegExp(r'[0-9]+'), '');
  final originalTokens = noNumbers
      .split(RegExp(r'\s+|,|;|\(|\)|\.|:|!|\?|\[|\]'))
      .where((t) => t.isNotEmpty)
      .toList();
  // Filtrovanie podľa normalizovaných tokenov
  final filtered = originalTokens.where((t) => !ignoredTokens.contains(normalize(t))).toList();
  return filtered.join(' ').trim();
}

// Porovnáva položky v košíku case-insensitive a bez diakritiky
bool cartContainsItem(Iterable<String> cartValues, String item) {
  final normItem = normalize(item);
  return cartValues.any((e) => normalize(e) == normItem);
}
