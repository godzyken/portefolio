import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/parametres/themes/services/theme_repository.dart';
import '../../features/parametres/themes/theme/theme_data.dart';

class BootstrapService {
  final BasicTheme theme;
  final SharedPreferences prefs;

  BootstrapService({required this.theme, required this.prefs});

  static Future<BootstrapService> initialize() async {
    developer.log('🚀 BootstrapService starting...');

    final prefs = await _initializeSharedPreferences();
    await _initializeHive();

    final repo = ThemeRepository(prefs: prefs);
    final theme = await repo.loadTheme();

    developer.log('✅ BootstrapService finished.');

    return BootstrapService(theme: theme, prefs: prefs);
  }

  static Future<SharedPreferences> _initializeSharedPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      developer.log('⚠️ SharedPreferences unavailable, using fallback.');
      return FakeSharedPreferences();
    }
  }

  static Future<void> _initializeHive() async {
    const int basicThemeAdapterId = 10;

    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
      }

      if (!Hive.isAdapterRegistered(basicThemeAdapterId)) {
        Hive.registerAdapter<BasicTheme>(BasicThemeAdapter());
        developer.log('👍 BasicThemeAdapter registered.');
      }

      if (!Hive.isBoxOpen('themes')) {
        await Hive.openBox<BasicTheme>('themes');
        developer.log("📦 Hive box 'themes' opened.");
      }
    } catch (e) {
      developer.log('❌ Hive initialization failed: $e');
      throw Exception('Hive init error.');
    }
  }
}
