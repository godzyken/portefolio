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
    developer.log('🚀 Démarrage de BootstrapService...');

    final prefs = await _initializeSharedPreferences();

    await _initializeHive();

    final repo = ThemeRepository(prefs: prefs);
    final theme = await repo.loadTheme();

    developer.log('✅ BootstrapService terminé.');

    return BootstrapService(theme: theme, prefs: prefs);
  }

  /// Initialise SharedPreferences avec un fallback pour les plateformes non supportées.
  static Future<SharedPreferences> _initializeSharedPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      developer
          .log('⚠️ SharedPreferences non disponible, fallback mémoire : $e');
      // FakeSharedPreferences doit être une classe qui implémente SharedPreferences avec une Map.
      return FakeSharedPreferences();
    }
  }

  /// Initialise Hive, enregistre les adaptateurs et ouvre les boîtes nécessaires.
  static Future<void> _initializeHive() async {
    const int basicThemeAdapterId = 10; // L'ID de votre adaptateur

    try {
      // Pour le web, `Hive.initFlutter()` gère tout.
      // Pour les autres plateformes, il a besoin d'un chemin.
      if (!kIsWeb) {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      } else {
        // Alternative plus simple pour toutes les plateformes si vous utilisez hive_flutter
        Hive.ignoreTypeId(basicThemeAdapterId);
      }

      // Enregistrer l'adaptateur pour BasicTheme s'il n'est pas déjà enregistré.
      if (!Hive.isAdapterRegistered(basicThemeAdapterId)) {
        Hive.registerAdapter(BasicThemeAdapter());
        developer.log('👍 Adaptateur BasicThemeAdapter enregistré.');
      }

      // Ouvrir la boîte 'themes' pour la rendre accessible dans toute l'application.
      if (!Hive.isBoxOpen('themes')) {
        await Hive.openBox<BasicTheme>('themes');
        developer.log("✅ Boîte Hive 'themes' ouverte avec succès.");
      }
    } catch (e) {
      developer.log('❌ Erreur critique lors de l\'initialisation de Hive: $e');
      // Vous pourriez vouloir remonter l'erreur ici si Hive est essentiel.
      throw Exception('Impossible d\'initialiser la base de données locale.');
    }
  }
}
