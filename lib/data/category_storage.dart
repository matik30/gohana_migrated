import 'package:hive/hive.dart';
import '../models/recipe.dart';

/// Trieda na správu kategórií receptov pomocou Hive databázy.
/// Umožňuje pridávať, premenovávať, mazať a resetovať kategórie.
class CategoryStorage {
  /// Názov Hive boxu pre kategórie
  static const String boxName = 'categories';
  /// Zoznam predvolených kategórií
  static const List<String> defaultCategories = [
    'Soup',
    'Meat and fish',
    'Meatless meal',
    'Appetizers',
    'Desserts',
    'Drinks',
    'Others',
  ];

  /// Otvorí Hive box pre kategórie (asynchrónne)
  static Future<Box> openBox() async {
    return await Hive.openBox<String>(boxName);
  }

  /// Získa zoznam kategórií, ak je box prázdny, naplní ho predvolenými hodnotami
  static Future<List<String>> getCategories() async {
    final box = await openBox();
    if (box.isEmpty) {
      await box.addAll(defaultCategories);
    }
    return box.values.cast<String>().toList();
  }

  /// Pridá novú kategóriu
  static Future<void> addCategory(String name) async {
    final box = await openBox();
    await box.add(name);
  }

  /// Premenuje kategóriu a aktualizuje všetky recepty, ktoré ju používajú
  static Future<void> renameCategory(int index, String newName, String oldName) async {
    final box = await openBox();
    final key = box.keyAt(index);
    await box.put(key, newName);
    // Aktualizuje všetky recepty s pôvodnou kategóriou
    final recipeBox = Hive.box<Recipe>('recipes');
    for (final rKey in recipeBox.keys) {
      final recipe = recipeBox.get(rKey);
      if (recipe != null && recipe.category == oldName) {
        recipe.category = newName;
        await recipe.save();
      }
    }
  }

  /// Vymaže kategóriu a všetky recepty s touto kategóriou presunie do 'Others'
  static Future<void> deleteCategory(int index) async {
    final box = await openBox();
    final key = box.keyAt(index);
    final deletedCategory = box.get(key);
    await box.delete(key);
    // Presunie recepty do 'Others'
    final recipeBox = Hive.box<Recipe>('recipes');
    for (final rKey in recipeBox.keys) {
      final recipe = recipeBox.get(rKey);
      if (recipe != null && recipe.category == deletedCategory) {
        recipe.category = 'Others';
        await recipe.save();
      }
    }
  }

  /// Resetuje kategórie na predvolené a všetky recepty s neznámou kategóriou presunie do 'Others'
  static Future<void> resetToDefault() async {
    final box = await openBox();
    await box.clear();
    await box.addAll(defaultCategories);
    // Nastaví 'Others' pre recepty s neznámou kategóriou
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
