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
final routerNotifierProvider = Provider<ValueNotifier<void>>((ref) {
  return ValueNotifier(null);
});

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
final servicesFutureProvider = FutureProvider<List<Service>>((ref) async {
  final jsonStr = await ui.rootBundle.loadString('assets/data/services.json');
  final List jsonList = jsonDecode(jsonStr);
  return jsonList.map((json) => Service.fromJson(json)).toList();
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

/// Liste globale des images (tu l’alimentes depuis projets, expériences, services)
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

/// Provider qui précache toutes les images de l’app
final precacheAllAssetsProvider = FutureProvider<void>((ref) async {
  final context = ref.read(navigatorKeyProvider).currentContext;
  if (context == null) return;

  /// 1. Fonts
  await loadCustomFont(
    'assets/fonts/Noto_Sans/NotoSans-Italic-VariableFont_wdth-wght.ttf',
    'NotoSansItalic',
  );
  await loadCustomFont(
    'assets/fonts/Noto_Sans/NotoSans-VariableFont_wdth-wght.ttf',
    'NotoSans',
  );

  /// 2. Images
  final images = await ref.read(appImagesProvider.future);

  for (final url in images) {
    final imageProvider = url.startsWith('http')
        ? NetworkImage(url)
        : AssetImage(url) as ImageProvider;

    try {
      if (context.mounted) await precacheImage(imageProvider, context);
      developer.log('✅ Image précachée: $url');
    } catch (e) {
      developer.log('❌ Erreur de précache: $url →', error: e);
    }
  }
});

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
