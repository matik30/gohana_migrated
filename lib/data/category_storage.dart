import 'package:hive/hive.dart';
import '../models/recipe.dart';

class CategoryStorage {
  static const String boxName = 'categories';
  static const List<String> defaultCategories = [
    'Soup',
    'Meat and fish',
    'Meatless meal',
    'Appetizers',
    'Desserts',
    'Drinks',
    'Others',
  ];

  static Future<Box> openBox() async {
    return await Hive.openBox<String>(boxName);
  }

  static Future<List<String>> getCategories() async {
    final box = await openBox();
    if (box.isEmpty) {
      await box.addAll(defaultCategories);
    }
    return box.values.cast<String>().toList();
  }

  static Future<void> addCategory(String name) async {
    final box = await openBox();
    await box.add(name);
  }

  static Future<void> renameCategory(int index, String newName, String oldName) async {
    final box = await openBox();
    final key = box.keyAt(index);
    await box.put(key, newName);
    // Update recipes
    final recipeBox = Hive.box<Recipe>('recipes');
    for (final rKey in recipeBox.keys) {
      final recipe = recipeBox.get(rKey);
      if (recipe != null && recipe.category == oldName) {
        recipe.category = newName;
        await recipe.save();
      }
    }
  }

  static Future<void> deleteCategory(int index) async {
    final box = await openBox();
    final key = box.keyAt(index);
    final deletedCategory = box.get(key);
    await box.delete(key);
    // Move recipes to 'Others'
    final recipeBox = Hive.box<Recipe>('recipes');
    for (final rKey in recipeBox.keys) {
      final recipe = recipeBox.get(rKey);
      if (recipe != null && recipe.category == deletedCategory) {
        recipe.category = 'Others';
        await recipe.save();
      }
    }
  }

  static Future<void> resetToDefault() async {
    final box = await openBox();
    await box.clear();
    await box.addAll(defaultCategories);
    // Update recipes: set category to 'Others' if not in default
    final recipeBox = Hive.box<Recipe>('recipes');
    for (final rKey in recipeBox.keys) {
      final recipe = recipeBox.get(rKey);
      if (recipe != null && (recipe.category == null || !defaultCategories.contains(recipe.category))) {
        recipe.category = 'Others';
        await recipe.save();
      }
    }
  }
}
