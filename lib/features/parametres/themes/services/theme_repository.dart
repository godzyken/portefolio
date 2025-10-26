import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_data.dart';

class ThemeRepository {
  static const _modeKey = 'theme_mode';
  static const _colorKey = 'theme_primary_color';

  final SharedPreferences _prefs;

  ThemeRepository({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveTheme(BasicTheme theme) async {
    await _prefs.setString(_modeKey, theme.mode.name);
    await _prefs.setInt(_colorKey, theme.primaryColor.toARGB32());
  }

  Future<BasicTheme> loadTheme() async {
    final modeString = _prefs.getString(_modeKey);
    final colorInt = _prefs.getInt(_colorKey);

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

class FakeSharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Object? get(String key) => _data[key];

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async {
    // Rien à persister réellement dans le FakeSharedPreferences
    return true;
  }

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  Future<void> reload() async {}

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }
}
