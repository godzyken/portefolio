import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../features/experience/data/experiences_data.dart';
import '../../features/generator/data/location_data.dart';
import '../../features/generator/providers/errors/geolocation_exception.dart';
import '../../features/generator/providers/location_service_provider.dart';
import '../notifier/location_notifiers.dart';
import 'location_settings_provider.dart';

/// 🔹 Provider pour le statut de permission GPS
final locationPermissionProvider =
    FutureProvider<LocationPermissionStatus>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.checkPermission();
});

/// 🔹 Provider pour activer/demander la permission
final requestLocationPermissionProvider =
    FutureProvider<LocationPermissionStatus>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.requestPermission();
});

/// 🔹 Provider pour le flux en temps réel (mise à jour continue)
final locationStreamProvider = StreamProvider.autoDispose<LocationData>((ref) {
  final service = ref.watch(locationServiceProvider);
  final settings = ref.watch(locationSettingsProvider);

  return service.getLocationStream(settings: settings).handleError((e) {
    ref
        .read(locationErrorProvier.notifier)
        .setError(e is GeolocationException ? e : null);
  });
});

/// 🔹 Provider pour savoir si le GPS est activé
final isGpsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.isLocationEnabled();
});

/// 🔹 Gère la configuration des options de la carte de manière centralisée
final mapConfigProvider = Provider.family<MapOptions, LatLng>((ref, centerPos) {
  // 1. Constantes de configuration
  const double defaultZoom = 16.0;
  const double webZoom = 13.0;
  final parisBounds = LatLngBounds(
    LatLng(48.85, 2.34),
    LatLng(48.87, 2.36),
  );

  // 2. Logique spécifique au Web (Mode Statique / Démo)
  if (kIsWeb) {
    return const MapOptions(
      initialCenter: LatLng(48.8566, 2.3522), // Paris par défaut
      initialZoom: webZoom,
      minZoom: 3.0,
      maxZoom: 18.0,
      interactionOptions: InteractionOptions(
        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
    );
  }

  // 3. Logique Mobile (Mode GPS Temps Réel)
  return MapOptions(
    initialCenter: centerPos,
    initialZoom: defaultZoom,
    cameraConstraint: CameraConstraint.contain(bounds: parisBounds),
    interactionOptions: const InteractionOptions(
      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      enableMultiFingerGestureRace: true,
    ),
    minZoom: 3.0,
    maxZoom: 18.0,
    keepAlive: true,
  );
});

final userLocationProvider =
    StreamNotifierProvider<UserLocationNotifier, LocationData>(
        UserLocationNotifier.new);

final sigPointsProvider = Provider.family<List<LatLng>, LatLng>((ref, center) {
  final rng = Random();
  // 5 points aléatoires autour de l'utilisateur
  return List.generate(
      5,
      (_) => LatLng(
            center.latitude + (rng.nextDouble() - 0.5) / 500,
            center.longitude + (rng.nextDouble() - 0.5) / 500,
          ));
});

/// 🔹 Points SIG proches basés sur la dernière position utilisateur
final nearbySigPointsProvider = Provider<AsyncValue<List<LatLng>>>((ref) {
  return ref.watch(userLocationProvider).whenData((pos) {
    final userLatLng = LatLng(pos.latitude, pos.longitude);
    return ref.watch(sigPointsProvider(userLatLng));
  });
});

final satelliteModeProvider =
    NotifierProvider<SatelliteModeNotifier, bool>(SatelliteModeNotifier.new);

final mapTileProvider = Provider<TileProvider>((ref) {
  if (kIsWeb) {
    return NetworkTileProvider();
  }

  // Configuration Mobile First : Utilisation de FMTC
  // .allStores() permet d'utiliser n'importe quel magasin de tuiles déjà téléchargé
  return FMTCTileProvider.allStores(
    loadingStrategy:
        BrowseLoadingStrategy.cacheFirst, // Priorité rapidité (Mobile)
    allStoresStrategy:
        BrowseStoreStrategy.readUpdateCreate, // Évite l'écriture inutile
    cachedValidDuration: const Duration(days: 30), // Cache longue durée
    recordHitsAndMisses: true,
  );
});

/// 🔹 Regroupe l'état global du service de localisation (GPS activé + Permission)
final locationStateProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(locationServiceProvider);

  final isGpsEnabled = await service.isLocationEnabled();
  if (!isGpsEnabled) return false;

  final permission = await service.checkPermission();
  return permission == LocationPermissionStatus.granted ||
      permission == LocationPermissionStatus.grantedLimited;
});

final workExperiencesProvider =
    FutureProvider<List<WorkExperience>>((ref) async {
  // Simulez le chargement ou utilisez rootBundle.loadString('assets/data/experiences.json')
  final List<dynamic> data = [/* Votre JSON ici */];
  return data.map((e) => WorkExperience.fromJson(e)).toList();
});

/// 🔹 Filtre les points SIG pour n'afficher que les lieux de travail
final experienceMarkersProvider = Provider<List<Marker>>((ref) {
  final experiences = ref.watch(workExperiencesProvider).value ?? [];

  return experiences.map((exp) {
    return Marker(
      point: exp.location,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {}, // Logique de popup
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4)
                  ],
                ),
                child: const Icon(Icons.business_center,
                    color: Colors.blue, size: 20),
              ),
              const Icon(Icons.arrow_drop_down,
                  color: Colors.white, weight: 10),
            ],
          ),
        ),
      ),
    );
  }).toList();
});

/// 🔹 Index actuel de la visite guidée (-1 si inactive)
final tourIndexProvider =
    NotifierProvider<TourIndexNotifier, int>(TourIndexNotifier.new);

final careerPathProvider = Provider<List<LatLng>>((ref) {
  final experiences = ref.watch(workExperiencesProvider).value ?? [];
  // On récupère les points de chaque expérience dans l'ordre du JSON
  return experiences.map((e) => e.location).toList();
});
