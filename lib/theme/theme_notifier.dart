import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gohana_migrated/theme/colors.dart';

// ThemeNotifier – trieda na správu a uchovávanie témy (svetlá/tmavá) v aplikácii
class ThemeNotifier extends ChangeNotifier {
  // Kľúč pre uloženie preferencie do SharedPreferences
  static const _kKey = 'darkMode';

  // Aktuálny stav témy (true = tmavá, false = svetlá)
  bool _isDark;

  // Konštruktor s počiatočnou hodnotou témy
  ThemeNotifier(this._isDark);

  // Getter pre aktuálny stav témy
  bool get isDark => _isDark;

  // Centralizované gettery pre farby podľa aktuálnej témy
  Color get bgColor => _isDark ? AppDarkColors.background : AppColors.background;
  Color get accentColor => _isDark ? AppDarkColors.accent : AppColors.accent;
  Color get accentSoftColor => _isDark ? AppDarkColors.accentSoft : AppColors.accentSoft;
  Color get panelColor => _isDark ? AppDarkColors.panel : AppColors.panel;
  Color get textColor => _isDark ? AppDarkColors.text : AppColors.text;
  Color get smallColor => _isDark ? AppDarkColors.small : AppColors.small;
  // Pridajte ďalšie farby podľa potreby

  // Nastaví tému (svetlá/tmavá), uloží do SharedPreferences a notifikácia poslucháčov
  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, _isDark);
  }

  // Prepne tému na opačnú (toggle)
  Future<void> toggle() async => setDark(!_isDark);

  // Factory metóda: vytvorí ThemeNotifier a načíta uloženú hodnotu z SharedPreferences
  static Future<ThemeNotifier> create() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_kKey) ?? false;
    return ThemeNotifier(isDark);
  }
}
