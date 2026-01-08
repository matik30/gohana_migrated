import 'dart:io';
import 'package:flutter/material.dart';

/// Widget na univerzálne zobrazenie obrázka receptu (asset alebo file)
class RecipeImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
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
    if (imageUrl.isEmpty) {
      return placeholder ?? const Icon(Icons.image_not_supported);
    }
    final isAsset = imageUrl.startsWith('assets/');
    final imageWidget = isAsset
        ? Image.asset(imageUrl, fit: fit, width: width, height: height)
        : Image.file(File(imageUrl), fit: fit, width: width, height: height);
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }
}
