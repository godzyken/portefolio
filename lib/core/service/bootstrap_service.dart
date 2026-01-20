import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portefolio/features/home/data/services_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/parametres/themes/services/theme_repository.dart';
import '../../features/parametres/themes/theme/theme_data.dart';
import '../provider/image_providers.dart';
import 'config_env_service.dart';

class BootstrapService {
  final BasicTheme theme;
  final SharedPreferences prefs;

  BootstrapService({required this.theme, required this.prefs});

  static Future<BootstrapService> initialize() async {
    developer.log('🚀 BootstrapService starting...');

    final prefs = await _initializeSharedPreferences();
    await _initializeHive();
    await _prepareMapEngine();

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

  static Future<void> _prepareMapEngine() async {
    if (!kIsWeb) {
      try {
        // Vérification rapide de l'état du moteur
        final stats = FMTCRoot.stats;
        developer
            .log('🗺️ FMTC Root stats: ${stats.storesAvailable} stores actifs');

        // On crée le store s'il n'existe pas
        final store = const FMTCStore('mapStore');
        final bool exists = await store.manage.ready;

        if (!exists) {
          // 2. S'il n'existe pas, on le crée
          await store.manage.create();
          developer.log('📦 Nouveau store "mapStore" créé');
        } else {
          // 3. S'il existe, on nettoie les tuiles obsolètes
          final expiry =
              DateTime.timestamp().subtract(const Duration(days: 30));

          // Retourne le nombre de tuiles "orphelines" supprimées
          return await store.manage.removeTilesOlderThan(expiry: expiry);
        }
      } catch (e) {
        developer.log('⚠️ Erreur moteur FMTC, tentative de récupération...');
        FMTCRoot.recovery;
      }
    }
  }

  static Future<int> cleanMapCache() async {
    if (kIsWeb) return 0;

    final store = const FMTCStore('mapStore');
    if (await store.manage.ready) {
      // Calcul de la date limite (ex: 14 jours selon la doc)
      final expiry = DateTime.timestamp().subtract(const Duration(days: 14));

      // Retourne le nombre de tuiles "orphelines" supprimées
      store.manage.removeTilesOlderThan(expiry: expiry);
      return store.stats.length;
    }
    return 0;
  }

  Future<void> loadJsonData() async {
    String jsonString =
        await rootBundle.loadString('assets/data/services.json');

    // Au lieu de : final data = parseServices(jsonString);
    // Utilisez compute pour ne pas bloquer l'UI
    final List<Service> services = await compute(parseServices, jsonString);

    developer.log("✅ ${services.length} services chargés sans bloquer l'UI");
  }

  Future<void> prefetchAll(WidgetRef ref, BuildContext context) async {
    // 1. Précacher les images classiques
    final rasters = await ref.read(rasterImagesProvider.future);
    for (var path in rasters) {
      if (context.mounted) {
        precacheImage(AssetImage(path), context).catchError((e) {
          developer.log('⚠️ Échec précache image: $path');
        });
      }
    }

    // 2. Précacher les SVG (évite l'erreur ImageCodecException)
    final svgs = await ref.read(svgImagesProvider.future);
    for (var path in svgs) {
      final loader = SvgAssetLoader(path);
      // Charge les bytes en cache sans passer par le moteur de rendu d'image classique
      svg.cache
          .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }

    // 3. LOTTIE / JSON (Optionnel)
    // On ne les passe JAMAIS dans precacheImage.
    // Si vous voulez les charger en RAM :
    await ref.read(lottieAssetsProvider.future);

    developer.log('✅ Précache terminé.');
  }

  Future<void> smartPrecache(List<String> images, BuildContext context) async {
    for (String path in images) {
      try {
        // On ajoute un timeout pour éviter de bloquer le démarrage
        final String lowPath = path.toLowerCase();

        if (lowPath.endsWith('.json')) {
          continue;
        }

        if (lowPath.endsWith('.svg')) {
          // Pré-chargement SVG (via flutter_svg)
          final loader = SvgAssetLoader(path);
          await vg.loadPicture(loader, context);
        } else {
          // Pré-chargement classique
          await precacheImage(AssetImage(path), context)
              .timeout(const Duration(milliseconds: 500));
        }
      } catch (e) {
        developer.log('⚠️ Saut de l\'asset (trop long ou invalide): $path');
      }
    }
  }

  Future<double> getMapCacheSize() async {
    if (kIsWeb) return 0.0;

    int totalBytes = 0;

    try {
      // 1. Récupérer la liste de tous les stores (objets FMTCStore)
      final List<FMTCStore> stores = await FMTCRoot.stats.storesAvailable;

      // 2. Parcourir chaque store pour récupérer ses statistiques
      for (final store in stores) {
        // On récupère les stats globales du store spécifique
        final stats = await store.stats.all;
        totalBytes += stats.size.ceil();
      }
    } catch (e) {
      developer
          .log('⚠️ Erreur lors du calcul de la taille totale du cache: $e');
    }

    // 3. Conversion octets -> Mo
    return totalBytes / (1024 * 1024);
  }
}
