import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_data.dart';

class ThemeRepository {
  static const _modeKey = 'theme_mode';
  static const _colorKey = 'theme_primary_color';

  Future<void> saveTheme(BasicTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, theme.mode.name);
    await prefs.setInt(_colorKey, theme.primaryColor.toARGB32());
  }

  Future<BasicTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final modeString = prefs.getString(_modeKey);
    final colorInt = prefs.getInt(_colorKey);

    final mode = AppThemeMode.values.firstWhere(
      (e) => e.name == modeString,
      orElse: () => AppThemeMode.system,
    );

    final color = colorInt != null ? Color(colorInt) : Colors.teal;

    return BasicTheme(
      mode: mode,
      primaryColorValue: color.toARGB32(),
      tertiaryColorValue: color.toARGB32(),
      neutralColorValue: color.toARGB32(),
    );
  }
}
