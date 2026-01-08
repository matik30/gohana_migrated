import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gohana_migrated/theme/colors.dart';

// Simple ThemeNotifier using SharedPreferences to persist dark/light choice.
class ThemeNotifier extends ChangeNotifier {
  static const _kKey = 'darkMode';

  bool _isDark;

  ThemeNotifier(this._isDark);

  bool get isDark => _isDark;

  // Centralized color getters
  Color get bgColor => _isDark ? AppDarkColors.background : AppColors.background;
  Color get accentColor => _isDark ? AppDarkColors.accent : AppColors.accent;
  Color get accentSoftColor => _isDark ? AppDarkColors.accentSoft : AppColors.accentSoft;
  Color get panelColor => _isDark ? AppDarkColors.panel : AppColors.panel;
  Color get textColor => _isDark ? AppDarkColors.text : AppColors.text;
  Color get smallColor => _isDark ? AppDarkColors.small : AppColors.small;
  // Add more as needed for your app

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, _isDark);
  }

  Future<void> toggle() async => setDark(!_isDark);

  // Factory: create and load saved value
  static Future<ThemeNotifier> create() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_kKey) ?? false;
    return ThemeNotifier(isDark);
  }
}
