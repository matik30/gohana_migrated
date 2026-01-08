import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

Future<void> migrateAddCategory({String defaultCategory = 'Meatless meal'}) async {
  final box = Hive.box<Recipe>('recipes');
  for (final key in box.keys.toList()) {
    final r = box.get(key);
    if (r == null) continue;
    if (r.category == null) {
      final updated = Recipe(
        title: r.title,
        imageUrl: r.imageUrl,
        ingredients: List<String>.from(r.ingredients),
        procedure: r.procedure,
        category: defaultCategory,
      );
      await box.put(key, updated);
    }
  }
}