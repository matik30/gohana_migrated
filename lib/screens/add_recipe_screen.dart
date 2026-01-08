import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:gohana_migrated/theme/fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../data/category_storage.dart';
import 'package:hive/hive.dart';
import '../models/recipe.dart';
import '../utils/recipe_image.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _procedureController;
  late List<TextEditingController> _ingredientControllers;
  String? _selectedCategory;
  String? _imagePath;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _procedureController = TextEditingController();
    _ingredientControllers = [TextEditingController()];
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryStorage.getCategories();
    setState(() {
      _categories = cats;
      if (_selectedCategory == null && cats.isNotEmpty) {
        _selectedCategory = cats.first;
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      String path = picked.path;
      // Kontrola content URI
      // If you get a content:// URI, you may need to use a different plugin (like file_picker) to resolve it.
      // For now, just set the path as is. If you encounter issues, consider using file_picker for better compatibility.
      setState(() => _imagePath = path);
    }
  }

  void _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    final box = await Hive.openBox<Recipe>('recipes');
    final ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final recipe = Recipe(
      title: _titleController.text.trim(),
      imageUrl: _imagePath ?? '',
      ingredients: ingredients,
      procedure: _procedureController.text.trim(),
      category: _selectedCategory,
      favourite: false,
    );
    await box.add(recipe);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bg = themeNotifier.bgColor;
    final accent = themeNotifier.accentColor;
    final panel = themeNotifier.panelColor;
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
              'Add Recipe',
              style: AppTextStyles.heading1(context, themeNotifier),
            ),
            leading: BackButton(color: Theme.of(context).colorScheme.secondary),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      themeNotifier.isDark
                          ? 'assets/images/GohanaDark.png'
                          : 'assets/images/Gohana.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(color: accent.withValues(alpha: 0.5), width: 4),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Title',
                  style: AppTextStyles.heading2(context, themeNotifier),
                ),
                TextFormField(
                  controller: _titleController,
                  style: AppTextStyles.body(context, themeNotifier),
                  decoration: InputDecoration(
                    hintText: 'Recipe name',
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
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 16),
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
                Text(
                  'Ingredients',
                  style: AppTextStyles.heading2(context, themeNotifier),
                ),
                ..._ingredientControllers.asMap().entries.map(
                  (e) => Row(
                    children: [
                      Expanded(
                        child: TextFormField(
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
                          validator: (value) => null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: small,
                        onPressed: () {
                          setState(
                            () => _ingredientControllers.removeAt(e.key),
                          );
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
                Text(
                  'Procedure',
                  style: AppTextStyles.heading2(context, themeNotifier),
                ),
                TextFormField(
                  controller: _procedureController,
                  style: AppTextStyles.body(context, themeNotifier),
                  decoration: InputDecoration(
                    hintText: 'Procedure',
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
                  maxLines: 6,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter procedure' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: AppTextStyles.heading2Accent(
                      context,
                      themeNotifier,
                    ),
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
        ),
      ),
      backgroundColor: bg,
    );
  }
}
