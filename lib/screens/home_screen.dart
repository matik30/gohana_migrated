import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/colors.dart';
import 'package:gohana_migrated/theme/fonts.dart';
import 'package:provider/provider.dart';
import 'package:gohana_migrated/theme/theme_notifier.dart';

import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import '../data/category_storage.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/recipe_share.dart';
import 'package:file_saver/file_saver.dart';
import '../utils/recipe_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    RecipesTab(),
    SizedBox.shrink(), // placeholder for Cart tab
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/cart');
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // get current theme colors from provider (only variables used in this method)
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bg = themeNotifier.bgColor;
    final accent = themeNotifier.accentColor;
    final accentSoft = themeNotifier.accentSoftColor;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: bg,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Recipes'),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.accent, width: 2),
        ),
        backgroundColor: accentSoft,
        foregroundColor: accent,
        child: const Icon(Icons.add, weight: 400),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class RecipesTab extends StatefulWidget {
  const RecipesTab({super.key});

  @override
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
  List<String> _categories = [];
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = null;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryStorage.getCategories();
    if (!mounted) return;
    setState(() => _categories = cats);
  }

  void _showEditCategoriesDialog() async {
    if (!mounted) return;
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final panel = themeNotifier.panelColor;
    final accent = themeNotifier.accentColor;
    final small = themeNotifier.smallColor;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        final controllerList = List.generate(
          _categories.length,
          (i) => TextEditingController(text: _categories[i]),
        );
        String newCategory = '';
        return Dialog(
          backgroundColor: panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: accent.withValues(alpha: .5), width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Categories',
                  style: AppTextStyles.heading2(context, themeNotifier),
                ),
                const SizedBox(height: 16),
                ...List.generate(_categories.length, (i) {
                  final isOthers = _categories[i] == 'Others';
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllerList[i],
                          style: AppTextStyles.body(context, themeNotifier),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            filled: true,
                            fillColor: themeNotifier.bgColor,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: accent.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: accent, width: 2),
                            ),
                          ),
                          enabled: !isOthers,
                          onChanged: isOthers
                              ? null
                              : (val) {
                                  final oldName = _categories[i];
                                  CategoryStorage.renameCategory(
                                    i,
                                    val,
                                    oldName,
                                  ).then((_) {
                                    if (!mounted) return;
                                    setState(() => _categories[i] = val);
                                  });
                                },
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isOthers ? Icons.lock : Icons.delete,
                          color: isOthers
                              ? small.withValues(alpha: 0.5)
                              : small.withValues(alpha: 0.8),
                          size: 22,
                        ),
                        tooltip: isOthers ? 'Cannot delete Others' : 'Delete',
                        onPressed: isOthers
                            ? null
                            : () {
                                Navigator.of(dialogContext).pop();
                                CategoryStorage.deleteCategory(i).then((_) {
                                  if (!mounted) return;
                                  _loadCategories().then((_) {
                                    if (!mounted) return;
                                    _showEditCategoriesDialog();
                                  });
                                });
                              },
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: AppTextStyles.body(context, themeNotifier),
                        decoration: InputDecoration(
                          hintText: 'Add new category',
                          hintStyle: AppTextStyles.small(
                            context,
                            themeNotifier,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: themeNotifier.bgColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: accent.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: accent, width: 2),
                          ),
                        ),
                        onChanged: (val) => newCategory = val,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: accent, size: 22),
                      tooltip: 'Add',
                      onPressed: () {
                        if (newCategory.trim().isNotEmpty) {
                          Navigator.of(dialogContext).pop();
                          CategoryStorage.addCategory(newCategory.trim()).then((
                            _,
                          ) {
                            if (!mounted) return;
                            _loadCategories().then((_) {
                              if (!mounted) return;
                              _showEditCategoriesDialog();
                            });
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: accent,
                        textStyle: AppTextStyles.smallText(
                          context,
                          themeNotifier,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        CategoryStorage.resetToDefault().then((_) {
                          if (!mounted) return;
                          _loadCategories();
                        });
                      },
                      child: Text(
                        'Reset to default',
                        style: AppTextStyles.smallText(context, themeNotifier),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: small,
                        textStyle: AppTextStyles.smallText(
                          context,
                          themeNotifier,
                        ),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        'Close',
                        style: AppTextStyles.smallText(context, themeNotifier),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareCookbook() async {
    final box = Hive.box<Recipe>('recipes');
    final recipes = box.values.toList().cast<Recipe>();
    if (recipes.isEmpty) return;
    final file = await exportCookbookToZip(recipes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Gohana Cookbook',
      ),
    );
  }

  Future<void> _archiveCookbook() async {
    final box = Hive.box<Recipe>('recipes');
    final recipes = box.values.toList().cast<Recipe>();
    if (recipes.isEmpty) return;
    final file = await exportCookbookToZip(recipes);
    final bytes = await file.readAsBytes();
    await FileSaver.instance.saveAs(
      name: 'Gohana_Cookbook',
      bytes: bytes,
      fileExtension: 'gohana',
      mimeType: MimeType.zip,
    );
  }

  // helper: find key for a recipe (match by title+image as a simple heuristic)
  dynamic _keyForRecipe(Box<Recipe> box, Recipe recipe) {
    for (final key in box.keys) {
      final r = box.get(key);
      if (r != null &&
          r.title == recipe.title &&
          r.imageUrl == recipe.imageUrl) {
        return key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Recipe>('recipes');
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bg = themeNotifier.bgColor;
    final panel = themeNotifier.panelColor;
    final accent = themeNotifier.accentColor;
    final small = themeNotifier.smallColor;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48), // výška AppBaru
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
              'Recipes',
              style: AppTextStyles.heading1(context, themeNotifier),
            ),
            leading: Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, _) {
                final dark = themeNotifier.isDark;
                return PopupMenuButton<int>(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  color: themeNotifier.panelColor,
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        themeNotifier.toggle();
                        break;
                      case 1:
                        _showEditCategoriesDialog();
                        break;
                      case 2:
                        _archiveCookbook();
                        break;
                      case 3:
                        _shareCookbook();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(
                              Icons.dark_mode,
                              color: themeNotifier.textColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Dark mode',
                              style: AppTextStyles.smallText(
                                context,
                                themeNotifier,
                              ),
                            ),
                            const Spacer(),
                            if (dark)
                              Icon(
                                Icons.check,
                                color: themeNotifier.textColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: themeNotifier.textColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Edit',
                              style: AppTextStyles.smallText(
                                context,
                                themeNotifier,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        enabled: true,
                        child: Row(
                          children: [
                            Icon(
                              Icons.archive,
                              color: themeNotifier.textColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Archive',
                              style: AppTextStyles.smallText(
                                context,
                                themeNotifier,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 3,
                        enabled: true,
                        child: Row(
                          children: [
                            Icon(
                              Icons.group,
                              color: themeNotifier.textColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Share cookbook',
                              style: AppTextStyles.smallText(
                                context,
                                themeNotifier,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                );
              },
            ),
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
              borderRadius: BorderRadius.circular(50), // 50 % corner radius
              side: BorderSide(color: accent.withValues(alpha: 0.5), width: 4),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<Box<Recipe>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          final recipes = box.values.toList().cast<Recipe>();
          // group recipes by category; if recipe has no category, treat as 'Others'
          final Map<String, List<Recipe>> groupedRecipes = {};
          for (final recipe in recipes) {
            final category = recipe.category ?? 'Others';
            groupedRecipes.putIfAbsent(category, () => []).add(recipe);
          }

          if (groupedRecipes.isEmpty) {
            return const Center(child: Text('No recipes'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: _categories.length,
            itemBuilder: (context, idx) {
              final cat = _categories[idx];
              var items = groupedRecipes[cat] ?? <Recipe>[];
              // Sort: favourites first
              items = List<Recipe>.from(items);
              items.sort(
                (a, b) => (b.favourite ? 1 : 0) - (a.favourite ? 1 : 0),
              );
              final isOpen = _expandedIndex == idx;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isOpen ? panel : bg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // header
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() {
                        // toggle: if tapping the already open category -> close it;
                        // otherwise open the tapped one and close previous
                        _expandedIndex = (_expandedIndex == idx) ? null : idx;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat,
                                    style: (_expandedIndex == idx)
                                        ? AppTextStyles.heading2Accent(
                                            context,
                                            themeNotifier,
                                          )
                                        : AppTextStyles.heading2(
                                            context,
                                            themeNotifier,
                                          ),
                                  ),
                                  if (!(_expandedIndex == idx))
                                    Text(
                                      '${items.length} recipes',
                                      style: AppTextStyles.small(
                                        context,
                                        themeNotifier,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              (_expandedIndex == idx)
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_right,
                              color: small,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // expanded grid shows recipes
                    if (_expandedIndex == idx)
                      Container(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                            bottom: Radius.circular(5),
                          ),
                        ),
                        child: items.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No recipes',
                                  style: AppTextStyles.smallText(
                                    context,
                                    themeNotifier,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 4 / 4,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final recipe = items[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/detail',
                                      arguments: recipe,
                                    ),
                                    onLongPress: () {
                                      final key = _keyForRecipe(box, recipe);
                                      if (key != null) box.delete(key);
                                    },
                                    child: Stack(
                                      children: [
                                        Card(
                                          color: panel,
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: RecipeImage(
                                                  imageUrl: recipe.imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ),
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      recipe.title,
                                                      style:
                                                          AppTextStyles.smallText(
                                                            context,
                                                            themeNotifier,
                                                          ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (recipe.favourite)
                                          Positioned(
                                            right: 6,
                                            bottom: 6,
                                            child: Icon(
                                              Icons.favorite,
                                              color: accent,
                                              size: 18,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
