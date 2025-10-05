import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:portefolio/core/service/analytics_service.dart';
import 'package:portefolio/features/generator/data/location_data.dart';
import 'package:portefolio/features/generator/notifiers/hover_map_notifier.dart';

import '../../constants/app_tab.dart';
import '../../constants/tech_logos.dart';
import '../../features/generator/data/extention_models.dart';
import '../../features/generator/services/location_service.dart';
import '../../features/generator/services/pdf_export_service.dart';
import '../affichage/navigator_key_provider.dart';
import '../exeptions/state/global_error_state.dart';
import '../logging/app_logger.dart';
import '../notifier/notifiers.dart';

/// Titre dynamique de l’AppBar
final appBarTitleProvider =
    NotifierProvider<AppBarTitleNotifier, String>(AppBarTitleNotifier.new);

/// Actions dynamiques de l’AppBar
final appBarActionsProvider =
    NotifierProvider<AppBarActionsNotifier, List<Widget>>(
        AppBarActionsNotifier.new);

/// Drawer dynamique
final appBarDrawerProvider =
    NotifierProvider<AppBarDrawerNotifier, Widget?>(AppBarDrawerNotifier.new);

/// Location route actuelle
final currentLocationProvider =
    NotifierProvider<CurrentLocationNotifier, String>(
        CurrentLocationNotifier.new);

/// Notifie quand on veut forcer un refresh
final routerNotifierProvider =
    NotifierProvider<RouterNotifier, String>(RouterNotifier.new);

/// Stream qui émet la location courante
final routeLocationStreamProvider = StreamProvider<String>((ref) {
  final controller = StreamController<String>.broadcast();

  controller.add(ref.read(currentLocationProvider));

  ref.listen(currentLocationProvider, (p, n) {
    controller.add(n);
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

/// Tab position actuelle
final currentTabProvider = Provider<AppTab>((ref) {
  final asyncLoc = ref.watch(routeLocationStreamProvider);
  final location = asyncLoc.asData?.value ?? '/';
  return AppTab.fromLocation(location);
});

/// Index actuelle
final currentIndexProvider = Provider<int>((ref) {
  return ref.watch(currentTabProvider).index;
});

// Exemple : état de chargement du PDF
final isGeneratingProvider =
    NotifierProvider<IsGeneratingNotifier, bool>(IsGeneratingNotifier.new);

// Etat de la page courante
final isPageViewProvider =
    NotifierProvider<IsPageViewNotifier, bool>(IsPageViewNotifier.new);

// Etat de detection du survol d'un élément
final hoverMapProvider = NotifierProvider<HoverMapNotifier, Map<String, bool>>(
  HoverMapNotifier.new,
);

// Etat du lecteur YoutubeVideoIframe
final playingVideoProvider =
    NotifierProvider<PlayingVideoNotifier, String?>(PlayingVideoNotifier.new);

// Liste des projets sélectionnés
final selectedProjectsProvider =
    NotifierProvider<SelectedProjectsNotifier, List<ProjectInfo>>(
        SelectedProjectsNotifier.new);

// Listes des expériences
final experiencesProvider =
    NotifierProvider<ExperiencesNotifier, List<Experience>>(
        ExperiencesNotifier.new);
final experiencesFutureProvider = FutureProvider<List<Experience>>((ref) async {
  final jsonStr = await ui.rootBundle.loadString(
    'assets/data/experiences.json',
  );
  final List<dynamic> jsonList = jsonDecode(jsonStr);
  return jsonList.map((json) => Experience.fromJson(json)).toList();
});

// Filtre des expériences
final experienceFilterProvider =
    NotifierProvider<ExperienceFilterNotifier, String?>(
        ExperienceFilterNotifier.new);
final filterExperiencesProvider = Provider<List<Experience>>((ref) {
  final List<Experience> all = ref
      .watch(experiencesFutureProvider)
      .maybeWhen(data: (d) => d, orElse: () => <Experience>[]);
  final filter = ref.watch(experienceFilterProvider);

  if (filter == null || filter.isEmpty) return all;

  return all.where((exp) => exp.tags.contains(filter)).toList();
});

// List des Services proposer
final servicesProvider = FutureProvider<List<Service>>((ref) async {
  try {
    debugPrint('📦 Chargement des services...');

    final jsonStr = await ui.rootBundle.loadString('assets/data/services.json');
    final List jsonList = jsonDecode(jsonStr);

    final services = jsonList
        .map((json) {
          try {
            return Service.fromJson(json);
          } catch (e) {
            debugPrint('⚠️ Erreur parsing service: $e');
            return null;
          }
        })
        .whereType<Service>()
        .toList();

    if (services.isEmpty) {
      debugPrint('⚠️ JSON vide, utilisation des services par défaut');
      return defaultServices;
    }

    // Trier par priorité
    services.sort((a, b) => a.priority.compareTo(b.priority));

    debugPrint('✅ ${services.length} services chargés');
    return services;
  } catch (e, stack) {
    debugPrint('❌ Erreur chargement services: $e');
    debugPrint('Stack: $stack');
    return defaultServices;
  }
});

/// Provider pour filtrer les services par catégorie
final servicesFilterProvider =
    NotifierProvider<ServiceFilterNotifier, ServiceCategory?>(
  ServiceFilterNotifier.new,
);

/// Provider pour les services sélectionnés
final selectedServicesProvider =
    NotifierProvider<SelectedServicesNotifier, List<Service>>(
  SelectedServicesNotifier.new,
);

/// Provider des services filtrés
final filteredServicesProvider = Provider<List<Service>>((ref) {
  final services = ref.watch(servicesProvider).asData?.value ?? [];
  final filter = ref.watch(servicesFilterProvider);

  if (filter == null) return services;

  return services.where((s) => s.category == filter).toList();
});

/// Provider pour obtenir un service par ID
final serviceByIdProvider = Provider.family<Service?, String>((ref, id) {
  final services = ref.watch(servicesProvider).asData?.value ?? [];
  try {
    return services.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});

/// Provider pour obtenir les catégories disponibles
final availableCategoriesProvider = Provider<List<ServiceCategory>>((ref) {
  final services = ref.watch(servicesProvider).asData?.value ?? [];
  final categories = services.map((s) => s.category).toSet().toList();
  categories.sort((a, b) => a.displayName.compareTo(b.displayName));
  return categories;
});

/// Provider pour compter les services par catégorie
final serviceCountByCategoryProvider =
    Provider.family<int, ServiceCategory>((ref, category) {
  final services = ref.watch(servicesProvider).asData?.value ?? [];
  return services.where((s) => s.category == category).length;
});

// Liste des projets
final projectsFutureProvider = FutureProvider<List<ProjectInfo>>((ref) async {
  final jsonStr = await ui.rootBundle.loadString('assets/data/projects.json');
  final List<dynamic> jsonList = jsonDecode(jsonStr);
  return jsonList.map((json) => ProjectInfo.fromJson(json)).toList();
});

// Génerateur de PDF
final pdfExportProvider = Provider<PdfExportService>((ref) {
  return PdfExportService();
});

// Etat du badge WakaTime
final wakatimeBadgeProvider = Provider.family<String?, String>((
  ref,
  projectName,
) {
  return wakatimeBadges[projectName];
});

// Etat de la geolocalisation
final positionProvider = StreamProvider<List<LatLng>>((ref) {
  final positionAsync = ref.watch(userLocationProvider);

  return positionAsync.when(
    data: (pos) async* {
      // Simule la recherche de données SIG autour de l’utilisateur
      final nearbyPoints = [
        LatLng(pos.latitude + 0.001, pos.longitude),
        LatLng(pos.latitude - 0.001, pos.longitude + 0.001),
        LatLng(pos.latitude, pos.longitude - 0.001),
      ];
      yield nearbyPoints;
    },
    error: (error, _) async* {
      if (kDebugMode) {
        developer.log('Erreur de localisation: $error');
      }
      // Yield empty list en cas d'erreur
      yield <LatLng>[];
    },
    loading: () async* {
      // Yield empty list pendant le chargement
      yield <LatLng>[];
    },
  );
});

final userLocationProvider =
    StreamNotifierProvider<UserLocationNotifier, LocationData>(
        UserLocationNotifier.new);

final sigPointsProvider = Provider.family<List<LatLng>, LatLng>((ref, userPos) {
  final rng = Random();
  // 5 points aléatoires autour de l'utilisateur
  return List.generate(5, (index) {
    final dx = (rng.nextDouble() - 0.5) / 500;
    final dy = (rng.nextDouble() - 0.5) / 500;
    return LatLng(userPos.latitude + dx, userPos.longitude + dy);
  });
});

final followUserProvider =
    NotifierProvider<FollowUserNotifier, bool>(FollowUserNotifier.new);

final mapControllerProvider = Provider<MapController>((ref) => MapController());

final mapConfigProvider = Provider<MapOptions Function(LatLng)>((ref) {
  return (LatLng userPos) {
    return MapOptions(
      initialCenter: userPos,
      initialZoom: 16.0,
      initialRotation: 0.0,
      initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(
              [LatLng(48.85, 2.34), LatLng(48.87, 2.36)])),
      interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          enableMultiFingerGestureRace: true),
      minZoom: 3.0,
      maxZoom: 18.0,
      keepAlive: true,
      backgroundColor: Colors.grey.shade100,
      cameraConstraint: CameraConstraint.contain(
          bounds: LatLngBounds.fromPoints(
              [LatLng(48.85, 2.34), LatLng(48.87, 2.36)])),
    );
  };
});

const _gaTrackingId = 'G-WQRTDMK3';

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(_gaTrackingId);
});

Future<List<String>> loadAssetsFromManifest({String? filter}) async {
  final manifestContent = await ui.rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  // 🔹 On récupère tous les chemins d’assets
  final assets = manifestMap.keys.toList();

  // 🔹 Optionnel : filtrer par dossier
  if (filter != null) {
    return assets.where((path) => path.startsWith(filter)).toList();
  }
  return assets;
}

Future<void> loadCustomFont(String assetPath, String family) async {
  final byteData = await ui.rootBundle.load(assetPath);
  final fontLoader = ui.FontLoader(family)..addFont(Future.value(byteData));
  await fontLoader.load();
}

/// Liste globale des images
final appImagesProvider = FutureProvider<List<String>>((ref) async {
  // 1. Charger toutes les images dans assets/images/
  final assetImages = await loadAssetsFromManifest(filter: 'assets/images/');

  // 2. Ajouter des images réseau
  final networkImages = [
    'https://www.tatvasoft.com/outsourcing/wp-content/uploads/2023/06/Angular-Architecture.jpg',
    'https://techpearl.com/wp-content/uploads/2021/11/Ionic-App.svg',
    'https://cenotia.com/wp-content/uploads/2017/05/transformation-digitale.jpg',
    'https://teachmeidea.com/wp-content/uploads/2025/04/ChatGPT-Image-Apr-3-2025-03_36_47-PM-1024x683.png',
    'https://storage.googleapis.com/cms-storage-bucket/build-more-with-flutter.f399274b364a6194c43d.png',
    'https://www.pyreweb.com/files/medias/images/Wordpress-Security-Issues-1.jpg',
    'https://www.reacteur.com/content/uploads/2018/05/magento-logo.png',
    'https://pro.packlink.fr/wp-content/uploads/2021/12/services-g0e8be1220_640-1.jpg',
  ];

  return [...assetImages, ...networkImages];
});

/// Provider qui précache toutes les images de l'app
final precacheAllAssetsProvider = FutureProvider<void>((ref) async {
  final context = ref.read(navigatorKeyProvider).currentContext;
  if (context == null) {
    debugPrint('❌ Context is null, cannot precache');
    return;
  }

  try {
    debugPrint('🎨 Début du précache des assets...');

    /// 1. Fonts
    debugPrint('📝 Chargement des fonts...');
    await loadCustomFont(
      'assets/fonts/Noto_Sans/NotoSans-Italic-VariableFont_wdth-wght.ttf',
      'NotoSansItalic',
    );
    await loadCustomFont(
      'assets/fonts/Noto_Sans/NotoSans-VariableFont_wdth-wght.ttf',
      'NotoSans',
    );
    debugPrint('✅ Fonts chargées');

    /// 2. Images
    debugPrint('🖼️ Chargement des images...');
    final images = await ref.read(appImagesProvider.future);
    debugPrint('📊 Total d\'images à précacher: ${images.length}');

    int successCount = 0;
    int errorCount = 0;

    // Séparer les images locales et réseau
    final localImages = images.where((url) => !url.startsWith('http')).toList();
    final networkImages =
        images.where((url) => url.startsWith('http')).toList();

    // Précacher les images locales en priorité (plus rapide)
    for (final url in localImages) {
      if (!context.mounted) break;

      try {
        await precacheImage(AssetImage(url), context);
        successCount++;
        debugPrint(
            '✅ Asset précaché ($successCount/${images.length}): ${url.split('/').last}');
      } catch (e) {
        errorCount++;
        debugPrint(
            '⚠️ Erreur asset ($errorCount): ${url.split('/').last} → $e');
      }
    }

    // Précacher les images réseau avec timeout et retry
    for (final url in networkImages) {
      if (!context.mounted) break;

      final success = await _precacheNetworkImageWithRetry(
        url,
        context,
        maxRetries: 2,
        timeout: const Duration(seconds: 10),
      );

      if (success) {
        successCount++;
        debugPrint(
            '✅ Network précaché ($successCount/${images.length}): ${Uri.parse(url).host}');
      } else {
        errorCount++;
        debugPrint('⚠️ Échec network ($errorCount): ${Uri.parse(url).host}');
      }
    }

    for (final url in images) {
      try {
        final imageProvider = url.startsWith('http')
            ? NetworkImage(url)
            : AssetImage(url) as ImageProvider;

        if (context.mounted) {
          await precacheImage(imageProvider, context);
          successCount++;
          debugPrint(
              '✅ Image précachée ($successCount/${images.length}): ${url.split('/').last}');
        }
      } catch (e) {
        errorCount++;
        debugPrint(
            '⚠️ Erreur de précache ($errorCount): ${url.split('/').last} → $e');
        // Continue même en cas d'erreur
      }
    }

    debugPrint(
        '🎉 Précache terminé: $successCount succès, $errorCount erreurs');
  } catch (e, stack) {
    debugPrint('❌ Erreur globale de précache: $e');
    debugPrint('Stack: $stack');
    // On ne throw pas pour ne pas bloquer l'app
  }
});

/// Fonction helper pour précacher une image réseau avec retry et timeout
Future<bool> _precacheNetworkImageWithRetry(
  String url,
  BuildContext context, {
  int maxRetries = 2,
  Duration timeout = const Duration(seconds: 10),
}) async {
  for (int attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      if (!context.mounted) return false;

      // Créer un completer avec timeout
      final imageProvider = NetworkImage(url);

      await precacheImage(imageProvider, context).timeout(
        timeout,
        onTimeout: () {
          debugPrint(
              '⏱️ Timeout pour: $url (tentative ${attempt + 1}/$maxRetries)');
          throw TimeoutException('Image loading timeout', timeout);
        },
      );

      return true; // Succès
    } catch (e) {
      if (attempt == maxRetries) {
        debugPrint('❌ Échec définitif après $maxRetries tentatives: $url');
        return false;
      }

      // Attendre avant de réessayer (backoff exponentiel)
      await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
  }

  return false;
}

/// Version alternative qui précache seulement les assets critiques
final precacheCriticalAssetsProvider = FutureProvider<void>((ref) async {
  final context = ref.read(navigatorKeyProvider).currentContext;
  if (context == null) return;

  debugPrint('🚀 Précache rapide des assets critiques...');

  try {
    // Seulement le logo et les fonts
    await loadCustomFont(
      'assets/fonts/Noto_Sans/NotoSans-VariableFont_wdth-wght.ttf',
      'NotoSans',
    );

    if (context.mounted) {
      await precacheImage(
        const AssetImage('assets/images/logo_godzyken.png'),
        context,
      );
    }

    debugPrint('✅ Assets critiques chargés');
  } catch (e) {
    debugPrint('⚠️ Erreur précache critique: $e');
  }
});

/// Version optimisée qui précache en parallèle (plus rapide mais plus de charge)
final precacheAllAssetsParallelProvider = FutureProvider<void>((ref) async {
  final context = ref.read(navigatorKeyProvider).currentContext;
  if (context == null) {
    debugPrint('❌ Context is null, cannot precache');
    return;
  }

  try {
    debugPrint('🎨 Début du précache parallèle des assets...');

    /// 1. Fonts
    await Future.wait([
      loadCustomFont(
        'assets/fonts/Noto_Sans/NotoSans-Italic-VariableFont_wdth-wght.ttf',
        'NotoSansItalic',
      ),
      loadCustomFont(
        'assets/fonts/Noto_Sans/NotoSans-VariableFont_wdth-wght.ttf',
        'NotoSans',
      ),
    ]);
    debugPrint('✅ Fonts chargées');

    /// 2. Images
    final images = await ref.read(appImagesProvider.future);
    debugPrint('📊 Total d\'images à précacher: ${images.length}');

    // Précacher en parallèle avec limite de concurrence
    final results = await _precacheImagesInBatches(
      images,
      context,
      batchSize: 5, // 5 images à la fois max
    );

    final successCount = results.where((r) => r).length;
    final errorCount = results.where((r) => !r).length;

    debugPrint(
        '🎉 Précache parallèle terminé: $successCount succès, $errorCount erreurs');
  } catch (e, stack) {
    debugPrint('❌ Erreur globale de précache parallèle: $e');
    debugPrint('Stack: $stack');
  }
});

/// Précache les images par lots pour éviter de surcharger le réseau
Future<List<bool>> _precacheImagesInBatches(
  List<String> images,
  BuildContext context, {
  int batchSize = 5,
}) async {
  final results = <bool>[];

  for (int i = 0; i < images.length; i += batchSize) {
    if (!context.mounted) break;

    final batch = images.skip(i).take(batchSize).toList();

    final batchResults = await Future.wait(
      batch.map((url) async {
        try {
          if (!context.mounted) return false;

          if (url.startsWith('http')) {
            return await _precacheNetworkImageWithRetry(
              url,
              context,
              maxRetries: 2,
              timeout: const Duration(seconds: 10),
            );
          } else {
            await precacheImage(AssetImage(url), context);
            return true;
          }
        } catch (e) {
          debugPrint('⚠️ Erreur batch: ${url.split('/').last} → $e');
          return false;
        }
      }),
    );

    results.addAll(batchResults);

    // Petit délai entre les lots
    if (i + batchSize < images.length) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  return results;
}

/// 🔹 Provider à utiliser dans l'app
final globalErrorProvider =
    NotifierProvider<GlobalErrorNotifier, GlobalErrorState?>(
        GlobalErrorNotifier.new);

/// 🔹 Provider pour le statut de permission GPS
final locationPermissionProvider =
    FutureProvider<LocationPermissionStatus>((ref) async {
  return await LocationService.instance.checkPermission();
});

/// 🔹 Provider pour activer/demander la permission
final requestLocationPermissionProvider =
    FutureProvider<LocationPermissionStatus>((ref) async {
  return await LocationService.instance.requestPermission();
});

/// 🔹 Provider pour la position actuelle (snapshot unique)
final currentActuLocationProvider = FutureProvider<LocationData?>((ref) async {
  return await LocationService.instance.getCurrentLocation();
});

/// 🔹 Provider pour le flux en temps réel (mise à jour continue)
final locationStreamProvider = StreamProvider<LocationData>((ref) {
  return LocationService.instance.getLocationStream();
});

/// 🔹 Provider pour savoir si le GPS est activé
final isGpsEnabledProvider = FutureProvider<bool>((ref) async {
  return await LocationService.instance.isLocationEnabled();
});

/// Fournit un logger spécifique à une catégorie (ex: HomeScreen, ExperiencesScreen)
final loggerProvider = Provider.family<AppLogger, String>((ref, category) {
  return AppLogger(category);
});

/*

final projectImagesProvider = FutureProvider<List<String>>((ref) async {
  return loadAssetsFromManifest(filter: 'assets/projects/');
});

final experienceImagesProvider = FutureProvider<List<String>>((ref) async {
  return loadAssetsFromManifest(filter: 'assets/experience/');
});

final serviceImagesProvider = FutureProvider<List<String>>((ref) async {
  return loadAssetsFromManifest(filter: 'assets/services/');
});

/// Regroupe tout
final appImagesProvider = FutureProvider<List<String>>((ref) async {
  final projects = await ref.read(projectImagesProvider.future);
  final experiences = await ref.read(experienceImagesProvider.future);
  final services = await ref.read(serviceImagesProvider.future);

  // 🔹 Ajoute les images réseaux si tu veux
  final networkImages = [
    'https://picsum.photos/400/800',
    'https://picsum.photos/300/600',
  ];

  return [...projects, ...experiences, ...services, ...networkImages];
});*/
