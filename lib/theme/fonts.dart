import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/theme_notifier.dart';

// Trieda obsahujúca všetky textové štýly používané v aplikácii
class AppTextStyles {
  // Nadpis 1 – veľký nadpis, používa akcentovú farbu podľa témy
  static TextStyle heading1(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playwrite US Trad',
      fontWeight: FontWeight.normal,
      fontSize: 24,
      color: themeNotifier.accentColor,
    );
  }

  // Nadpis 2 – menší nadpis, hlavná farba textu
  static TextStyle heading2(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: themeNotifier.textColor,
    );
  }

  // Nadpis 2 s akcentom – tučný, akcentová farba
  static TextStyle heading2Accent(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: themeNotifier.accentColor,
    );
  }

  // Základné telo textu (bežný text v aplikácii)
  static TextStyle body(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: themeNotifier.textColor,
    );
  }

  // Telo textu s akcentovou farbou (napr. zvýraznené časti)
  static TextStyle bodyAccent(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: themeNotifier.accentColor,
    );
  }

  // Telo textu pre disabled stav (neaktívny text)
  static TextStyle bodyDisabled(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: themeNotifier.smallColor.withValues(alpha: 0.5),
    );
  }

  // Malý text (napr. popisy, sekundárne informácie)
  static TextStyle small(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: themeNotifier.smallColor,
    );
  }

  // Malý text s hlavnou farbou textu
  static TextStyle smallText(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: themeNotifier.textColor,
    );
  }

  // Malý text s akcentovou farbou (napr. zvýraznené popisy)
  static TextStyle smallAccent(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: themeNotifier.accentColor,
    );
  }

  // Malý text pre disabled stav
  static TextStyle smallDisabled(BuildContext context, ThemeNotifier themeNotifier) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: themeNotifier.smallColor.withValues(alpha: 0.5),
    );
  }
}
