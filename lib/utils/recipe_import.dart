import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import '../models/recipe.dart';

/// Rozbalí .gohana ZIP a načíta zoznam receptov (a obrázky uloží do temp adresára).
Future<List<Recipe>> importRecipesFromZip(File zipFile) async {
  final tempDir = Directory.systemTemp.createTempSync('gohana_import');
  final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
  List<Recipe> recipes = [];
  for (final file in archive) {
    if (file.isFile && file.name == 'recipes.json') {
      final jsonStr = utf8.decode(file.content as List<int>);
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      recipes = jsonList.map((j) => Recipe.fromJson(j)).toList();
    } else if (file.isFile && file.name.endsWith('.jpg') || file.name.endsWith('.png')) {
      final outPath = '${tempDir.path}/${file.name}';
      File(outPath).writeAsBytesSync(file.content as List<int>);
      // Poznámka: obrázky sa zatiaľ len ukladajú, prepojenie s Recipe.imageUrl sa rieši pri importe
    }
  }
  // Pre každý recept nastav imageUrl na temp cestu, ak existuje
  for (final recipe in recipes) {
    final imgName = recipe.imageUrl.split('/').last;
    final imgFile = File('${tempDir.path}/$imgName');
    if (imgFile.existsSync()) {
      recipe.imageUrl = imgFile.path;
    }
  }
  return recipes;
}
