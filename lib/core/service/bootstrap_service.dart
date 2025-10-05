import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import '../../features/parametres/themes/services/theme_repository.dart';
import '../../features/parametres/themes/theme/theme_data.dart';

class BootstrapService {
  final BasicTheme theme;

  BootstrapService({required this.theme});

  static Future<BootstrapService> initialize() async {
    final repo = ThemeRepository();
    final theme = await repo.loadTheme();

    // ⚡ Démarrer les gros chargements sans bloquer l'UI
    unawaited(_warmupAsyncTasks());

    return BootstrapService(theme: theme);
  }

  static Future<void> _warmupAsyncTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      await Future.wait([
        // Lancement parallèle en tâche de fond
        rootBundle.loadString('assets/data/projects.json'),
        rootBundle.loadString('assets/data/experiences.json'),
        rootBundle.loadString('assets/data/services.json'),
      ]);
      developer.log('✅ Bootstrap warmup terminé');
    } catch (e) {
      developer.log('⚠️ Warmup async erreur: $e');
    }
  }
}
