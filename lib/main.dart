// Hlavný vstupný bod aplikácie Gohana
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

// Globálna premenná na zachytenie intentu z Androidu (napr. otvorenie .gohana súboru)
String? pendingImportUri;

void main() async {
  // Inicializácia Flutter bindingov a potrebných služieb
  WidgetsFlutterBinding.ensureInitialized();
  await loadIgnoredTokensGlobal(); // Načíta zoznam ignorovaných tokenov pre normalizáciu ingrediencií
  await Hive.initFlutter(); // Inicializuje Hive databázu
  Hive.registerAdapter(RecipeAdapter()); // Zaregistruje adapter pre model Recipe
  await Hive.openBox<Recipe>('recipes'); // Otvorí box s receptami
  await seedRecipes(); // Pridá základné recepty ak je box prázdny
  final themeNotifier = await ThemeNotifier.create(); // Inicializuje správcu témy

  // Nastavenie MethodChannel pre komunikáciu s natívnym Android kódom
  const platform = MethodChannel('gohana/intent');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'importGohanaFile') {
      pendingImportUri = call.arguments as String?;
    }
    return null;
  });
  platform.invokeMethod('flutterReady'); // Oznámi Androidu, že Flutter je pripravený

  // Spustenie aplikácie s poskytovateľom témy
  runApp(
    ChangeNotifierProvider<ThemeNotifier>.value(
      value: themeNotifier,
      child: GohanaApp(),
    ),
  );
}

// Hlavný widget aplikácie
class GohanaApp extends StatefulWidget {
  const GohanaApp({super.key});

  @override
  State<GohanaApp> createState() => _GohanaAppState();
}

class _GohanaAppState extends State<GohanaApp> {
  static const platform = MethodChannel('gohana/intent'); // Komunikácia s Androidom
  AppLinks? _appLinks; // Pre deep linky a file intent

  @override
  void initState() {
    super.initState();
    // Po prvom frame skontroluje, či neprišiel intent na import receptu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingImportUri != null) {
        _importGohanaFile(pendingImportUri!);
        pendingImportUri = null;
      }
    });
    // Nastaví handler pre MethodChannel (Android -> Flutter)
    platform.setMethodCallHandler(_handleIntent);
    // Listener na file intent/deep link cez app_links (napr. ak otvoríš .gohana cez iný spôsob)
    _appLinks = AppLinks();
    _appLinks!.uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        File? file;
        if (uri.scheme == 'file') {
          file = File(uri.path);
        } else if (uri.scheme == 'content') {
          // Ak je to content:// URI, získaj reálnu cestu cez platform channel
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
    });
  }

  // Handler pre MethodChannel (Android -> Flutter)
  Future<void> _handleIntent(MethodCall call) async {
    if (call.method == 'importGohanaFile') {
      final uri = call.arguments as String;
      await _importGohanaFile(uri);
    }
  }

  // Importuje recepty zo zadaného súboru (file:// alebo content://)
  Future<void> _importGohanaFile(String uri) async {
    File? file;
    if (uri.startsWith('file://')) {
      file = File(Uri.parse(uri).toFilePath());
    } else if (uri.startsWith('content://')) {
      // Získa reálnu cestu k súboru z content:// URI
      const platform = MethodChannel('gohana/content_uri');
      final tempPath = await platform.invokeMethod<String>('getFileFromContentUri', {'uri': uri});
      if (tempPath != null) file = File(tempPath);
    }
    if (file != null && file.existsSync()) {
      final recipes = await importRecipesFromZip(file);
      if (recipes.isNotEmpty && mounted) {
        _showImportDialog(recipes);
      }
    }
  }

  // Zobrazí dialóg na potvrdenie importu receptov
  // Používa AlertDialog s dvoma tlačidlami: Cancel a Import
  // Po potvrdení importu sa recepty pridajú do Hive boxu a prepne sa na HomeScreen
  void _showImportDialog(List<Recipe> recipes) async {
    if (!mounted) return; // Kontrola, či je widget stále v strome
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Cookbook'), // Nadpis dialógu
        content: Text('Do you want to import \\${recipes.length} recipes from the received cookbook?'), // Text s počtom receptov
        actions: [
          TextButton(
            child: const Text('Cancel'), // Tlačidlo na zrušenie
            onPressed: () => Navigator.of(ctx).pop(), // Zavrie dialóg
          ),
          TextButton(
            child: const Text('Import'), // Tlačidlo na potvrdenie importu
            onPressed: () async {
              final box = Hive.box<Recipe>('recipes'); // Získaj box s receptami
              for (final r in recipes) {
                await box.add(r); // Pridaj každý recept do boxu
              }
              if (!mounted) return; // Kontrola, či je widget stále v strome
              Navigator.of(context).pushReplacementNamed('/home'); // Prepne na HomeScreen
              // Automatický refresh: prepne na HomeScreen
            },
          ),
        ],
      ),
    );
  }

  // Vytvorí svetlú tému aplikácie
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

  // Vytvorí tmavú tému aplikácie
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

  // Build metóda - definuje MaterialApp a routovanie
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
