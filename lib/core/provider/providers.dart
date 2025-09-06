import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:portefolio/core/service/analytics_service.dart';
import 'package:portefolio/features/generator/notifiers/hover_map_notifier.dart';

import '../../constants/app_tab.dart';
import '../../constants/tech_logos.dart';
import '../../features/generator/data/extention_models.dart';
import '../../features/generator/services/pdf_export_service.dart';
import '../routes/router.dart';

/// Titre dynamique de l’AppBar
final appBarTitleProvider = StateProvider<String>((_) => "Portfolio");

/// Actions dynamiques de l’AppBar
final appBarActionsProvider = StateProvider<List<Widget>>((_) => []);

/// Drawer dynamique
final appBarDrawerProvider = StateProvider<Widget?>((_) => null);

/// Location route actuelle
final currentLocationProvider = Provider<String>((ref) {
  final router = ref.watch(goRouterProvider);
  return router.routerDelegate.currentConfiguration.last.matchedLocation;
});

/// Tab position actuelle
final currentTabProvider = Provider<AppTab>((ref) {
  final router = ref.watch(goRouterProvider);
  final location =
      router.routerDelegate.currentConfiguration.last.matchedLocation;
  return AppTab.fromLocation(location);
});

/// Index actuelle
final currentIndexProvider = Provider<int>((ref) {
  return ref.watch(currentTabProvider).index;
});

// Exemple : état de chargement du PDF
final isGeneratingProvider = StateProvider<bool>((ref) => false);

// Etat de la page courante
final isPageViewProvider = StateProvider<bool>((ref) => true);

// Etat de detection du survol d'un élément
final hoverMapProvider =
    StateNotifierProvider<HoverMapNotifier, Map<String, bool>>(
      (ref) => HoverMapNotifier(),
    );

// Etat du lecteur YoutubeVideoIframe
final playingVideoProvider = StateProvider<String?>((ref) => null);

// Liste des projets sélectionnés
final selectedProjectsProvider = StateProvider<List<ProjectInfo>>((ref) => []);

// Listes des expériences
final experiencesProvider = StateProvider<List<Experience>>((ref) => []);
final experiencesFutureProvider = FutureProvider<List<Experience>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/experiences.json');
  final List<dynamic> jsonList = jsonDecode(jsonStr);
  return jsonList.map((json) => Experience.fromJson(json)).toList();
});

// Filtre des expériences
final experienceFilterProvider = StateProvider<String?>((ref) => null);
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
  final jsonStr = await rootBundle.loadString('assets/data/services.json');
  final List jsonList = jsonDecode(jsonStr);
  return jsonList.map((json) => Service.fromJson(json)).toList();
});

// Liste des projets
final projectsFutureProvider = FutureProvider<List<ProjectInfo>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/projects.json');
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
    error: (_, _) async* {},
    loading: () async* {},
  );
});

final userLocationProvider = StreamProvider<Position>((ref) async* {
  // Demande la permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }

  // Retourne le flux de positions
  yield* Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // update every 5 meters
    ),
  );
});

final sigPointsProvider = Provider.family<List<LatLng>, LatLng>((ref, userPos) {
  final rng = Random();
  // 5 points aléatoires autour de l'utilisateur
  return List.generate(5, (index) {
    final dx = (rng.nextDouble() - 0.5) / 500;
    final dy = (rng.nextDouble() - 0.5) / 500;
    return LatLng(userPos.latitude + dx, userPos.longitude + dy);
  });
});

final followUserProvider = StateProvider<bool>((ref) => true);

final mapControllerProvider = Provider<MapController>((ref) => MapController());

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
