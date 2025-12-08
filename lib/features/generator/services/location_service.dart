import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../data/location_data.dart';

abstract class LocationService {
  static LocationService get instance => _PlatformLocationService();

  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<LocationData?> getCurrentLocation({Map<String, dynamic>? settings});
  Stream<LocationData> getLocationStream({Map<String, dynamic>? settings});
  Future<bool> isLocationEnabled();
  void dispose();
}

/// 🌐 / 📱 / Stub unifié
class _PlatformLocationService extends LocationService {
  final LocationService _impl;

  _PlatformLocationService() : _impl = _createService();

  static LocationService _createService() {
    if (kDebugMode) return _SimulatedLocationService();

    // 🎯 Utiliser Geolocator pour toutes les plateformes prises en charge
    // par Flutter (Web, Android, iOS, Windows, Mac, Linux).
    // On assume que geolocator gère les cas d'utilisation Web.
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      return _GeolocatorLocationService();
    }

    // 🖥️ Fallback for Desktop/Other (Stub/Simulated)
    return _StubLocationService();
  }

  @override
  Future<LocationPermissionStatus> checkPermission() => _impl.checkPermission();

  @override
  Future<LocationPermissionStatus> requestPermission() =>
      _impl.requestPermission();

  @override
  Future<LocationData?> getCurrentLocation({Map<String, dynamic>? settings}) =>
      _impl.getCurrentLocation(settings: settings);

  @override
  Stream<LocationData> getLocationStream({Map<String, dynamic>? settings}) =>
      _impl.getLocationStream(settings: settings);

  @override
  Future<bool> isLocationEnabled() => _impl.isLocationEnabled();

  @override
  void dispose() => _impl.dispose();
}

/// === Mobile/Web ===
class _GeolocatorLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final perm = await Geolocator.checkPermission();
      return _mapPermission(perm);
    } catch (e) {
      developer.log('❌ Erreur checkPermission: $e');
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final perm = await Geolocator.requestPermission();
      return _mapPermission(perm);
    } catch (e) {
      developer.log('❌ Erreur requestPermission: $e');
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationData?> getCurrentLocation(
      {Map<String, dynamic>? settings}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        developer.log('GPS désactivé, position simulée renvoyée');
        return null;
      }

      final locationSettings = _parseSettings(settings);

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      return _toLocationData(pos);
    } on PermissionDeniedException catch (e) {
      developer.log('❌ Permission refusée: $e');
      return null;
    } catch (e) {
      developer.log('❌ Erreur getCurrentLocation: $e');
      return null;
    }
  }

  @override
  Stream<LocationData> getLocationStream({Map<String, dynamic>? settings}) {
    final locationSettings = _parseSettings(settings);

    final stream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );

    return stream.map(_toLocationData);
  }

  @override
  Future<bool> isLocationEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      developer.log('❌ Erreur isLocationEnabled: $e');
      return false;
    }
  }

  LocationPermissionStatus _mapPermission(LocationPermission perm) {
    return switch (perm) {
      LocationPermission.denied ||
      LocationPermission.deniedForever =>
        LocationPermissionStatus.denied,
      LocationPermission.whileInUse => LocationPermissionStatus.whileInUse,
      LocationPermission.always => LocationPermissionStatus.always,
      LocationPermission.unableToDetermine =>
        LocationPermissionStatus.unableToDetermine,
    };
  }

  LocationData _toLocationData(Position pos) => LocationData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp,
      );

  LocationSettings _parseSettings(Map<String, dynamic>? settings) {
    if (settings == null) {
      return const LocationSettings(
          accuracy: LocationAccuracy.best, distanceFilter: 5);
    }

    // Extraction des paramètres
    final accuracy = settings['accuracy'] == 'high'
        ? LocationAccuracy.best
        : LocationAccuracy.low;
    final distanceFilter = (settings['distanceFilter'] as int?) ?? 5;

    // Pour Web (et autres), on peut aussi extraire maximumAge, timeout, etc.
    final intervalDuration =
        settings['intervalDuration'] as int?; // Pour Android

    // Note: Pour les autres paramètres spécifiques (activityType, etc.),
    // il faudrait une logique plus complexe si geolocator les prend en charge.

    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      // Pour Android seulement, peut être ignoré sur d'autres
      timeLimit: intervalDuration != null
          ? Duration(milliseconds: intervalDuration)
          : null,
    );
  }

  @override
  void dispose() {}
}

/// === Stub fallback (Desktop, autres) ===
class _StubLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    developer.log('🖥️ Stub: Pas de géolocalisation disponible');
    return LocationPermissionStatus.denied;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    developer.log('🖥️ Stub: Pas de géolocalisation disponible');
    return LocationPermissionStatus.denied;
  }

  @override
  Future<LocationData?> getCurrentLocation(
      {Map<String, dynamic>? settings}) async {
    developer.log('🖥️ Stub: Pas de géolocalisation disponible');
    return null;
  }

  @override
  Stream<LocationData> getLocationStream(
      {Map<String, dynamic>? settings}) async* {
    developer.log('🖥️ Stub: Stream vide');
  }

  @override
  Future<bool> isLocationEnabled() async {
    developer.log('🖥️ Stub: GPS non disponible');
    return false;
  }

  @override
  void dispose() {
    developer.log('🖥️ Stub: GPS no disponible');
  }
}

/// Service simulé pour mobile/desktop (position fixe)
class _SimulatedLocationService extends LocationService {
  StreamController<LocationData>? _controller;
  StreamSubscription? _periodicSub;

  static const _defaultLat = 48.8566;
  static const _defaultLng = 2.3522;

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    developer.log('📱 LocationService: Mode simulé - Permission accordée');
    return LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    developer.log('📱 LocationService: Mode simulé - Permission accordée');
    return LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationData?> getCurrentLocation(
      {Map<String, dynamic>? settings}) async {
    developer.log('📱 LocationService: Position simulée (Paris)');
    return _createFakeLocation();
  }

  @override
  Stream<LocationData> getLocationStream({Map<String, dynamic>? settings}) {
    _controller ??= StreamController<LocationData>.broadcast(
      onListen: _startEmitting,
      onCancel: _stopEmitting,
    );
    return _controller!.stream;
  }

  void _startEmitting() {
    developer.log('📱 SimulatedLocationService: start stream');

    // 🔥 1ère valeur immédiatement
    _emitPosition();

    // 🔥 Emission périodique SANS TIMER (compatible Web)
    _periodicSub = Stream.periodic(const Duration(seconds: 10))
        .listen((_) => _emitPosition());
  }

  void _emitPosition() {
    if (_controller == null || _controller!.isClosed) return;

    final loc = _createFakeLocation();
    _controller!.add(loc);

    developer.log('📱 SimulatedLocation: position emitted');
  }

  LocationData _createFakeLocation() => LocationData(
        latitude: _defaultLat,
        longitude: _defaultLng,
        accuracy: 100,
        timestamp: DateTime.now(),
      );

  void _stopEmitting() {
    developer.log('📱 SimulatedLocationService: stop stream');

    _periodicSub?.cancel();
    _periodicSub = null;

    _controller?.close();
    _controller = null;
  }

  @override
  Future<bool> isLocationEnabled() async {
    return true; // simulé => toujours dispo
  }

  @override
  void dispose() {
    _stopEmitting();
  }
}
