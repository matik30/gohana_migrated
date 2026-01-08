import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/theme_notifier.dart';

class AppTextStyles {
  // Returns heading1 style (uses accent color depending on theme)
  static TextStyle heading1(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playwrite US Trad',
      fontWeight: FontWeight.normal,
      fontSize: 24,
      color: themeNotifier.accentColor,
    );
  }

  static TextStyle heading2(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: themeNotifier.textColor,
    );
  }

  static TextStyle heading2Accent(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: themeNotifier.accentColor,
    );
  }

  static TextStyle body(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: themeNotifier.textColor,
    );
  }

  static TextStyle bodyAccent(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: themeNotifier.accentColor,
    );
  }

  static TextStyle bodyDisabled(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: themeNotifier.smallColor.withValues(alpha: 0.5),
    );
  }

  static TextStyle small(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: themeNotifier.smallColor,
    );
  }

  static TextStyle smallText(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: themeNotifier.textColor,
    );
  }

  static TextStyle smallAccent(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: themeNotifier.accentColor,
    );
  }

  static TextStyle smallDisabled(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: themeNotifier.smallColor.withValues(alpha: 0.5),
    );
  }
}
