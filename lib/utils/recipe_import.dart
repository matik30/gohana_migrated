import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe.dart';

/// Rozbalí .gohana ZIP a načíta zoznam receptov (a obrázky uloží do temp adresára).
Future<List<Recipe>> importRecipesFromZip(File zipFile) async {
  // Vytvorí dočasný adresár pre importované súbory
  final tempDir = Directory.systemTemp.createTempSync('gohana_import');
  // Rozbalí ZIP archív
  final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
  List<Recipe> recipes = [];
  for (final file in archive) {
    if (file.isFile && file.name == 'recipes.json') {
      // Ak je to recipes.json, načítaj zoznam receptov
      final jsonStr = utf8.decode(file.content as List<int>);
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      recipes = jsonList.map((j) => Recipe.fromJson(j)).toList();
    } else if (file.isFile && (file.name.endsWith('.jpg') || file.name.endsWith('.png'))) {
      // Ak je to obrázok, ulož ho do dočasného adresára
      final outPath = '${tempDir.path}/${file.name}';
      File(outPath).writeAsBytesSync(file.content as List<int>);
    }
  }
  // Pre každý recept nastav imageUrl na persistentnú cestu, ak existuje obrázok
  final docsDir = await getApplicationDocumentsDirectory();
  for (final recipe in recipes) {
    final imgName = recipe.imageUrl.split('/').last;
    final tempImgFile = File('${tempDir.path}/$imgName');
    if (tempImgFile.existsSync()) {
      // Skopíruj obrázok do trvalého adresára aplikácie a aktualizuj cestu v recepte
      final persistentImgPath = '${docsDir.path}/$imgName';
      await tempImgFile.copy(persistentImgPath);
      recipe.imageUrl = persistentImgPath;
    }
  }
  return recipes;
}
