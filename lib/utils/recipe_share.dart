import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import '../models/recipe.dart';

/// Exportuje recept (vrátane obrázka) do ZIP súboru pripraveného na zdieľanie.
Future<File> exportRecipeToZip(Recipe recipe) async {
  // 1. Priprav JSON s dátami receptu
  final recipeJson = jsonEncode(recipe.toJson());

  // 2. Priprav obrázok (ak existuje a je lokálny)
  List<int>? imageBytes;
  String? imageName;
  if (recipe.imageUrl.isNotEmpty && File(recipe.imageUrl).existsSync()) {
    imageBytes = await File(recipe.imageUrl).readAsBytes();
    imageName = recipe.imageUrl.split('/').last;
  }

  // 3. Vytvor ZIP
  final encoder = ZipFileEncoder();
  final tempDir = await getTemporaryDirectory();
  final zipPath = '${tempDir.path}/${recipe.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.gohana';
  encoder.create(zipPath);
  encoder.addFile(File(await _writeTempFile('recipe.json', recipeJson)));
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

  // Pridaj JSON so všetkými receptami
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
