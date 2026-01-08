import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/fonts.dart';
import 'package:gohana_migrated/theme/colors.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/recipe.dart';
import '../theme/theme_notifier.dart';
import '../utils/recipe_pdf.dart';
import '../utils/recipe_share.dart';
import 'edit_recipe_screen.dart';
import '../utils/recipe_image.dart';
import '../utils/ingredient_normalizer.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List.generate(widget.recipe.ingredients.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bg = themeNotifier.bgColor;
    final accent = themeNotifier.accentColor;
    //final small = themeNotifier.smallColor;
    final isFavourite = widget.recipe.favourite;

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
              widget.recipe.title,
              style: AppTextStyles.heading1(context, themeNotifier),
            ),
            leading: BackButton(color: Theme.of(context).colorScheme.secondary),
            actions: [
              PopupMenuButton<int>(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                color: themeNotifier.panelColor,
                onSelected: (value) async {
                  switch (value) {
                    case 0:
                      setState(() {
                        widget.recipe.favourite = !widget.recipe.favourite;
                      });
                      await widget.recipe.save();
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditRecipeScreen(recipe: widget.recipe),
                        ),
                      ).then((updatedRecipe) {
                        if (updatedRecipe != null && mounted) {
                          setState(() {}); // refresh detail after edit
                        }
                      });
                      break;
                    case 2:
                      final pdf = await recipeToPdf(widget.recipe);
                      await Printing.layoutPdf(
                        onLayout: (PdfPageFormat format) async => pdf.save(),
                      );
                      break;
                    case 3:
                      final file = await exportRecipeToZip(widget.recipe);
                      await SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(file.path)],
                          text: 'Gohana Recipe: ${widget.recipe.title}',
                        ),
                      );
                      break;
                    case 4:
                      final themeNotifier = Provider.of<ThemeNotifier>(
                        context,
                        listen: false,
                      );
                      final panel = themeNotifier.panelColor;
                      final accent = themeNotifier.accentColor;
                      final small = themeNotifier.smallColor;
                      final NavigatorState navigator = Navigator.of(context);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => Dialog(
                          backgroundColor: panel,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                            side: BorderSide(
                              color: accent.withValues(alpha: .5),
                              width: 3,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delete Recipe',
                                  style: AppTextStyles.heading2(
                                    context,
                                    themeNotifier,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Are you sure you want to delete this recipe? This action cannot be undone.',
                                  style: AppTextStyles.body(context, themeNotifier),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: small,
                                        textStyle: AppTextStyles.small(context, themeNotifier),
                                      ),
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: accent,
                                        textStyle: AppTextStyles.smallAccent(context, themeNotifier),
                                      ),
                                      onPressed: () => Navigator.of(dialogContext).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      if (confirmed == true) {
                        await widget.recipe.delete();
                        if (!mounted) return;
                        navigator.pop();
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: isFavourite ? accent : themeNotifier.textColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Favourite',
                          style: AppTextStyles.smallText(context, themeNotifier),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: themeNotifier.textColor, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: AppTextStyles.smallText(context, themeNotifier),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.print, color: themeNotifier.textColor, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Print',
                          style: AppTextStyles.smallText(context, themeNotifier),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        Icon(Icons.share, color: themeNotifier.textColor, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Send',
                          style: AppTextStyles.smallText(context, themeNotifier),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 4,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: themeNotifier.textColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: AppTextStyles.smallText(context, themeNotifier),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: RecipeImage(
                imageUrl: widget.recipe.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ingredients',
                    style: AppTextStyles.heading2(context, themeNotifier),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: _checked.contains(true)
                        ? accent
                        : Colors.grey,
                  ),
                  tooltip: 'Add selected to cart',
                  onPressed: _checked.contains(true) && globalIgnoredTokens != null
                      ? () async {
                          final navigator = Navigator.of(context);
                          final box = await Hive.openBox<String>('cart');
                          final selected = widget.recipe.ingredients
                              .asMap()
                              .entries
                              .where((e) => _checked[e.key])
                              .map((e) => filterIngredient(e.value, globalIgnoredTokens!))
                              .where((item) => item.isNotEmpty)
                              .toList();
                          for (final item in selected) {
                            if (!cartContainsItem(box.values, item)) {
                              await box.add(item);
                            }
                          }
                          if (mounted) {
                            navigator.pushNamed('/cart');
                          }
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...widget.recipe.ingredients.asMap().entries.map((e) {
              final i = e.key;
              final ingredient = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  // make rows more compact
                  visualDensity: const VisualDensity(
                    horizontal: 0,
                    vertical: -4.0,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.text,
                  checkColor: AppColors.background,
                  title: Text(
                    ingredient,
                    style: AppTextStyles.smallText(context, themeNotifier),
                  ),
                  value: _checked[i],
                  onChanged: (v) => setState(() => _checked[i] = v ?? false),
                ),
              );
            }),
            const SizedBox(height: 32),
            Text(
              'Procedure',
              style: AppTextStyles.heading2(context, themeNotifier),
            ),
            const SizedBox(height: 8),
            Text(
              widget.recipe.procedure,
              style: AppTextStyles.body(context, themeNotifier),
            ),
          ],
        ),
      ),
    );
  }
}
