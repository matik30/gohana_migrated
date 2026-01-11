import 'dart:io';
import 'package:flutter/material.dart';

/// Widget na univerzálne zobrazenie obrázka receptu (asset alebo file)
class RecipeImage extends StatelessWidget {
  // Cesta k obrázku (môže byť asset alebo file path)
  final String imageUrl;
  // Ako sa má obrázok prispôsobiť (napr. cover, contain)
  final BoxFit fit;
  // Šírka obrázka (voliteľné)
  final double? width;
  // Výška obrázka (voliteľné)
  final double? height;
  // Zaoblenie rohov (voliteľné)
  final BorderRadius? borderRadius;
  // Widget, ktorý sa zobrazí ak obrázok nie je dostupný (voliteľné)
  final Widget? placeholder;

  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    // Ak nie je zadaný obrázok, zobraz placeholder alebo ikonu
    if (imageUrl.isEmpty) {
      return placeholder ?? const Icon(Icons.image_not_supported);
    }
    // Rozlíši, či ide o asset obrázok alebo lokálny súbor
    final isAsset = imageUrl.startsWith('assets/');
    final imageWidget = isAsset
        ? Image.asset(imageUrl, fit: fit, width: width, height: height)
        : Image.file(File(imageUrl), fit: fit, width: width, height: height);
    // Ak je zadané zaoblenie rohov, obrázok sa oreže do tvaru
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    // Inak sa zobrazí obrázok bez orezania
    return imageWidget;
  }
}
