import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/fonts.dart';
import 'package:provider/provider.dart';
import 'package:gohana_migrated/theme/theme_notifier.dart';
import '../models/recipe.dart';
import '../data/category_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/recipe_image.dart';

/// Obrazovka na úpravu existujúceho receptu.
/// Umožňuje meniť názov, kategóriu, ingrediencie, postup a obrázok receptu.
class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe; // Recept, ktorý sa bude upravovať
  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late TextEditingController _titleController; // Ovládač pre názov
  late TextEditingController _procedureController; // Ovládač pre postup
  late List<TextEditingController> _ingredientControllers; // Ovládače pre ingrediencie
  String? _selectedCategory; // Aktuálne vybraná kategória
  String? _imagePath; // Cesta k obrázku
  List<String> _categories = []; // Zoznam kategórií

  @override
  void initState() {
    super.initState();
    // Inicializácia ovládačov s hodnotami z receptu
    _titleController = TextEditingController(text: widget.recipe.title);
    _procedureController = TextEditingController(text: widget.recipe.procedure);
    _ingredientControllers = widget.recipe.ingredients
        .map((i) => TextEditingController(text: i))
        .toList();
    _selectedCategory = widget.recipe.category;
    _imagePath = widget.recipe.imageUrl;
    _loadCategories();
  }

  /// Načíta kategórie z úložiska
  Future<void> _loadCategories() async {
    final cats = await CategoryStorage.getCategories();
    setState(() => _categories = cats);
  }

  /// Umožní vybrať nový obrázok z galérie
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  /// Uloží zmeny v recepte do Hive databázy
  void _saveRecipe() async {
    widget.recipe.title = _titleController.text.trim();
    widget.recipe.procedure = _procedureController.text.trim();
    widget.recipe.ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    widget.recipe.category = _selectedCategory;
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      widget.recipe.imageUrl = _imagePath!;
    }
    await widget.recipe.save();
    if (mounted) Navigator.pop(context, widget.recipe);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bg = themeNotifier.bgColor;
    final accent = themeNotifier.accentColor;
    final panel = themeNotifier.panelColor;
    //final textColor = themeNotifier.textColor;
    final small = themeNotifier.smallColor;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: SafeArea(
          top: true,
          bottom: false,
          child: AppBar(
            backgroundColor: bg,
            elevation: 0,
            centerTitle: true,
            titleSpacing: 0,
            toolbarHeight: 48,
            title: Text(
              'Edit Recipe',
              style: AppTextStyles.heading1(context, themeNotifier),
            ),
            leading: BackButton(color: Theme.of(context).colorScheme.secondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(color: accent.withValues(alpha: 0.5), width: 4),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Výber obrázka
            GestureDetector(
              onTap: _pickImage,
              child: _imagePath != null && _imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RecipeImage(
                        imageUrl: _imagePath!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                      ),
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Tap to select image',
                          style: AppTextStyles.smallText(
                            context,
                            themeNotifier,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Pole pre názov
            Text(
              'Title',
              style: AppTextStyles.heading2(context, themeNotifier),
            ),
            TextField(
              controller: _titleController,
              style: AppTextStyles.body(context, themeNotifier),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: AppTextStyles.bodyDisabled(context, themeNotifier),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Výber kategórie
            Text(
              'Category',
              style: AppTextStyles.heading2(context, themeNotifier),
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: _categories
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat,
                        style: AppTextStyles.body(context, themeNotifier),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              dropdownColor: panel,
              style: AppTextStyles.body(context, themeNotifier),
            ),
            const SizedBox(height: 16),
            // Zoznam ingrediencií
            Text(
              'Ingredients',
              style: AppTextStyles.heading2(context, themeNotifier),
            ),
            ..._ingredientControllers.asMap().entries.map(
              (e) => Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: e.value,
                      style: AppTextStyles.body(context, themeNotifier),
                      decoration: InputDecoration(
                        hintText: 'Ingredient ${e.key + 1}',
                        hintStyle: AppTextStyles.bodyDisabled(
                          context,
                          themeNotifier,
                        ),
                        filled: true,
                        fillColor: panel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: small,
                    onPressed: () {
                      setState(() => _ingredientControllers.removeAt(e.key));
                    },
                  ),
                ],
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
              style: TextButton.styleFrom(foregroundColor: accent),
              onPressed: () {
                setState(
                  () => _ingredientControllers.add(TextEditingController()),
                );
              },
            ),
            const SizedBox(height: 16),
            // Pole pre postup
            Text(
              'Procedure',
              style: AppTextStyles.heading2(context, themeNotifier),
            ),
            TextField(
              controller: _procedureController,
              style: AppTextStyles.body(context, themeNotifier),
              decoration: InputDecoration(
                hintText: 'Procedure',
                hintStyle: AppTextStyles.bodyDisabled(context, themeNotifier),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 24),
            // Tlačidlo na uloženie zmien
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: AppTextStyles.heading2Accent(context, themeNotifier),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
              ),
              onPressed: _saveRecipe,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      backgroundColor: bg,
    );
  }
}
