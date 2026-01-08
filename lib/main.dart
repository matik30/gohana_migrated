import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gohana_migrated/theme/colors.dart';
import 'package:gohana_migrated/theme/fonts.dart';
import 'package:provider/provider.dart';
import 'package:gohana_migrated/theme/theme_notifier.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'models/recipe.dart';
import 'utils/seed_data.dart';
import 'utils/recipe_import.dart';
import 'utils/ingredient_normalizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadIgnoredTokensGlobal();
  // inicializácia Hive pre Flutter
  await Hive.initFlutter();
  // zmaž starý box (odstráni všetky staré dáta, vrátane nekompatibilných)
  //await Hive.deleteBoxFromDisk('recipes');
  // zaregistruj adapter (vytvára sa cez build_runner ak používaš @HiveType)
  Hive.registerAdapter(RecipeAdapter());
  // otvorenie boxu (databázy) pre recepty
  await Hive.openBox<Recipe>('recipes');
  // naplň box mock dátami ak je prázdny
  await seedRecipes();
  // create ThemeNotifier (loads persisted SharedPreferences)
  final themeNotifier = await ThemeNotifier.create();

  //await migrateAddCategory(); // <- spusti migráciu tu (len raz)

  // voliteľné: vloženie seed dát len ak je box prázdny
  //await seedRecipes();
  runApp(
    ChangeNotifierProvider<ThemeNotifier>.value(
      value: themeNotifier,
      child: GohanaApp(),
    ),
  );
}

class GohanaApp extends StatefulWidget {
  const GohanaApp({super.key});

  @override
  State<GohanaApp> createState() => _GohanaAppState();
}

class _GohanaAppState extends State<GohanaApp> {
  AppLinks? _appLinks;
  @override
  void initState() {
    super.initState();
    // Listener na file intent/deep link cez app_links
    _appLinks = AppLinks();
    _appLinks!.uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.path.endsWith('.gohana')) {
        File? file;
        if (uri.scheme == 'file') {
          file = File(uri.path);
        } else if (uri.scheme == 'content') {
          // Platform channel na získanie reálneho súboru z content:// uri
          const platform = MethodChannel('gohana/content_uri');
          final tempPath = await platform.invokeMethod<String>('getFileFromContentUri', {'uri': uri.toString()});
          if (tempPath != null) file = File(tempPath);
        }
        if (file != null && file.existsSync()) {
          final recipes = await importRecipesFromZip(file);
          if (recipes.isNotEmpty && mounted) {
            _showImportDialog(recipes);
          }
        }
      }
    }, onError: (err) {});
  }

  void _showImportDialog(List<Recipe> recipes) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Cookbook'),
        content: Text('Do you want to import ${recipes.length} recipes from the received cookbook?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Import'),
            onPressed: () async {
              final box = Hive.box<Recipe>('recipes');
              for (final r in recipes) {
                await box.add(r);
              }
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/home');
              // Automatický refresh: prepne na HomeScreen
            },
          ),
        ],
      ),
    );
  }

  ThemeData _buildLightTheme(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final smallAccent = AppTextStyles.smallAccent(context, themeNotifier);
    final smallText = AppTextStyles.smallText(context, themeNotifier);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.background,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return smallAccent;
          }
          return smallText;
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent, size: 24);
          }
          return const IconThemeData(color: AppColors.text, size: 24);
        }),
      ),
    );
  }

  ThemeData _buildDarkTheme(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final smallAccent = AppTextStyles.smallAccent(context, themeNotifier);
    final smallText = AppTextStyles.smallText(context, themeNotifier);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppDarkColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppDarkColors.panel,
        foregroundColor: AppDarkColors.text,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppDarkColors.panel,
        indicatorColor: AppDarkColors.panel,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return smallAccent;
          }
          return smallText;
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppDarkColors.accent, size: 24);
          }
          return const IconThemeData(color: AppDarkColors.text, size: 24);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Gohana',
      theme: _buildLightTheme(context),
      darkTheme: _buildDarkTheme(context),
      themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/cart': (_) => const CartScreen(),
        '/add': (_) => const AddRecipeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final recipe = settings.arguments as Recipe;
          return MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          );
        }
        return null;
      },
    );
  }
}
