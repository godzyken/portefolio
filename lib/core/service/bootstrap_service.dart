import 'dart:async';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/parametres/themes/services/theme_repository.dart';
import '../../features/parametres/themes/theme/theme_data.dart';

class BootstrapService {
  final BasicTheme theme;
  final SharedPreferences prefs;

  BootstrapService({required this.theme, required this.prefs});

  static Future<BootstrapService> initialize() async {
    SharedPreferences prefs;

    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      developer
          .log('⚠️ SharedPreferences non disponible, fallback mémoire: $e');
      prefs = FakeSharedPreferences() as SharedPreferences; // cast temporaire
    }

    final repo = ThemeRepository(prefs: prefs);
    final theme = await repo.loadTheme();

    // ⚡ Démarrer les gros chargements sans bloquer l'UI
    developer.log('✅ BootstrapService terminé.');

    return BootstrapService(theme: theme, prefs: prefs);
  }
}
