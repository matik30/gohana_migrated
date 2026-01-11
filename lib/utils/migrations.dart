import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

// Migračná funkcia: pridá kategóriu k receptom, ktoré ju nemajú
// defaultCategory – predvolená kategória, ktorá sa nastaví (napr. "Meatless meal")
Future<void> migrateAddCategory({String defaultCategory = 'Meatless meal'}) async {
  // Otvorenie boxu s receptami
  final box = Hive.box<Recipe>('recipes');
  // Prejdi všetky kľúče (recepty)
  for (final key in box.keys.toList()) {
    final r = box.get(key);
    if (r == null) continue; // preskoč, ak recept neexistuje
    if (r.category == null) {
      // Ak recept nemá kategóriu, vytvor novú inštanciu s pridanou kategóriou
      final updated = Recipe(
        title: r.title,
        imageUrl: r.imageUrl,
        ingredients: List<String>.from(r.ingredients),
        procedure: r.procedure,
        category: defaultCategory,
      );
      // Ulož aktualizovaný recept späť do boxu
      await box.put(key, updated);
    }
  }
}