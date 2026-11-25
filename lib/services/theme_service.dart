import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'is_dark_mode';
  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier(ThemeMode.light);

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isCurrentlyDark = themeMode.value == ThemeMode.dark;
    themeMode.value = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool(_key, !isCurrentlyDark);
  }
}