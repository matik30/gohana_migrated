import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import '../models/recipe.dart';

/// Exportuje recept (vrátane obrázka) do ZIP súboru pripraveného na zdieľanie.
Future<File> exportRecipeToZip(Recipe recipe) async {
  // 1. Priprav JSON s dátami receptu (iba jeden recept)
  final recipeJson = jsonEncode(recipe.toJson());

  // 2. Priprav obrázok (ak existuje a je lokálny súbor)
  List<int>? imageBytes;
  String? imageName;
  if (recipe.imageUrl.isNotEmpty && File(recipe.imageUrl).existsSync()) {
    imageBytes = await File(recipe.imageUrl).readAsBytes();
    imageName = recipe.imageUrl.split('/').last;
  }

  // 3. Vytvor ZIP archív v dočasnom adresári
  final encoder = ZipFileEncoder();
  final tempDir = await getTemporaryDirectory();
  final zipPath = '${tempDir.path}/${recipe.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.gohana';
  encoder.create(zipPath);
  // Pridaj JSON receptu do ZIPu
  encoder.addFile(File(await _writeTempFile('recipe.json', recipeJson)));
  // Pridaj obrázok, ak existuje
  if (imageBytes != null && imageName != null) {
    encoder.addFile(File(await _writeTempFile(imageName, imageBytes, isBytes: true)));
  }
  encoder.close();
  return File(zipPath);
}

/// Exportuje všetky recepty (a ich obrázky) do ZIP súboru pripraveného na zdieľanie.
Future<File> exportCookbookToZip(List<Recipe> recipes) async {
  final tempDir = await getTemporaryDirectory();
  final zipPath = '${tempDir.path}/cookbook_${DateTime.now().millisecondsSinceEpoch}.gohana';
  final encoder = ZipFileEncoder();
  encoder.create(zipPath);

  // Vždy exportuj pole receptov vo formáte JSON
  final allRecipesJson = jsonEncode(recipes.map((r) => r.toJson()).toList());
  encoder.addFile(File(await _writeTempFile('recipes.json', allRecipesJson)));

  // Pridaj obrázky (iba unikátne, existujúce lokálne)
  final addedImages = <String>{};
  for (final recipe in recipes) {
    final imgPath = recipe.imageUrl;
    if (imgPath.isNotEmpty && File(imgPath).existsSync() && !addedImages.contains(imgPath)) {
      final imageName = imgPath.split('/').last;
      encoder.addFile(File(await _writeTempFile(imageName, await File(imgPath).readAsBytes(), isBytes: true)));
      addedImages.add(imgPath);
    }
  }
  encoder.close();
  return File(zipPath);
}

// Pomocná funkcia na zápis dočasného súboru (text alebo binárne dáta)
Future<String> _writeTempFile(String name, dynamic content, {bool isBytes = false}) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$name');
  if (isBytes) {
    await file.writeAsBytes(content as List<int>);
  } else {
    await file.writeAsString(content as String);
  }
  return file.path;
}
